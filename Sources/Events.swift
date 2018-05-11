//
//  Events.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//


import UIKit
import RxSwift

public struct Events<C : ReusableViewContainer, R : ReusableView, O: ObservableConvertibleType> {
    
    weak var container: C!
    
    private let obs: Observable<(R, O)>
    
    init(_ obs: Observable<(R, O)>) {
        self.obs = obs
    }
    
    /// A chance to transform the target Observable to another.
    ///
    /// - Parameter transformer: Just a transformer.
    /// - Returns: The new instance.
    public func with<U : ObservableConvertibleType>(_ transformer: @escaping (C, R, O) -> U) -> Events<C, R, U> {
        let newObs: Observable<(R, U)> = obs.map { (values) -> (R, U) in
            return (values.0, transformer(self.container, values.0, values.1))
        }
        
        var events = Events<C, R, U>(newObs)
        events.container = container
        return events
    }
    
    /// In fact, an instance of Events represents a second-order Observable, so this method is just that `merge`. 😄
    ///
    /// - Returns: An Observable.
    public func merge() -> Observable<O.E> {
        return merge(with: { $2 })
    }
    
    /// You want to change the final element from merging?
    ///
    /// - Parameter extra: A tranformer.
    /// - Returns: An Observable.
    public func merge<T>(with extra: @escaping (C, R, O.E) -> T) -> Observable<T> {
        return obs.flatMap({ (values) -> Observable<T> in
            return values.1.asObservable().map{ extra(self.container, values.0, $0) }
        })
    }
    
}


public extension Events where R : Indexed, R.IndexedViewType == C.IndexedType {
    
    func mergeWithIndexPath<T>(_ carried: @escaping (O.E, IndexPath?) -> T) -> Observable<T> {
        return merge(with: { (c, r, e) -> T in carried(e, c.indexPath(for: r as! C.IndexedType)) })
    }
    
    func mergeWithModel<T, M>(with modelType: M.Type, _ carried: @escaping (O.E, M?) -> T) -> Observable<T> {
        return merge(with: { (c, r, e) -> T in
            if let indexPath = c.indexPath(for: r as! C.IndexedType) {
                return carried(e, try? c.model(at: indexPath))
            }
            return carried(e, nil)
        })
    }
    
}



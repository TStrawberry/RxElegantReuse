//
//  Events.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//


import UIKit
import RxSwift
import RxCocoa

public struct Events<C : ReusableViewContainer, R : ReusableView, O: ObservableConvertibleType> {
    
    enum EventsError : String, Error {
        case unhandleError = "Catch a unhandled error"
    }
    
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
    
    public func catchEventsError(_ errorHandler: @escaping (Error) -> Observable<O.E>) -> Events<C, R, Observable<O.E>> {
        return with { (container, view, observable) -> Observable<O.E> in
            observable.asObservable()
                .catchError({ (error) -> Observable<O.E> in
                    return errorHandler(error)
                })
                .do(onError: { (error) in
                    fatalError(error.localizedDescription)
                })
        }
    }
    
    /// In fact, an instance of Events represents a second-order Observable, so this method is just that `merge`. 😄
    ///
    /// - Returns: An Observable.
    private func flatten(_ errorHandler: ((Error) -> Observable<O.E>)? = nil) -> Observable<O.E> {
        return flatten(with: { $2 }, errorHandler)
    }
    
    /// You want to change the final element from merging?
    ///
    /// - Parameter extra: A tranformer.
    /// - Returns: An Observable.
    private func flatten<T>(with extra: @escaping (C, R, O.E) -> T,
                           _ errorHandler: ((Error) -> Observable<O.E>)? = nil) -> Observable<T> {
        return obs.flatMap({ (values) -> Observable<T> in
            return values.1.asObservable()
                .catchError({ (error) -> Observable<O.E> in
                    return errorHandler?(error) ?? Observable.error(error)
                })
                .do(onError: { (error) in
                    fatalError(error.localizedDescription)
                })
                .map{ extra(self.container, values.0, $0) }
        })
    }

}

public extension Events where R : Indexed, R.IndexedViewType == C.IndexedType {
    
    func withIndexPath<T>(_ carried: @escaping (O.E, IndexPath?) -> T) -> Events<C, R, Observable<T>> {
        return with { (container, reusableView, observable) -> Observable<T> in
            observable.asObservable()
                .map { (e) -> T in
                    carried(e, container.indexPath(for: reusableView as! C.IndexedType))
                }
        }
    }
    
    func withModel<T, M>(with modelType: M.Type, _ carried: @escaping (O.E, M?) -> T) -> Events<C, R, Observable<T>> {
        return with { (container, reusableView, observable) -> Observable<T> in
            observable.asObservable()
                .map { (e) -> T in
                    if let indexPath = container.indexPath(for: reusableView as! C.IndexedType) {
                        return carried(e, try? container.model(at: indexPath))
                    }
                    return carried(e, nil)
                }
        }
    }
}

extension Events: ObservableType {
    public typealias E = O.E
    
    public func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, Events.E == O.E {
        return flatten().subscribe(observer)
    }
}

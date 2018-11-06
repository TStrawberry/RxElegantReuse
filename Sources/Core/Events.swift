//
//  Events.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import Foundation
import RxSwift

/// Represents an observable sequence that comes from flattening all observable sequence on reusables.
/// An `Events` instance should not fail, so please make sure that you catched all the errors on reusable.
public struct Events<C : ReusableContainer, R : ReusableObject, O : ObservableConvertibleType> {
    
    enum EventsError : String, Error {
        case unhandleError = "Catch a unhandled error"
    }
    
    weak var container: C!
    
    private let obs: Observable<(R, O)>
    
    init(_ obs: Observable<(R, O)>) {
        self.obs = obs
    }
    
    /// Create a new Event instance from the original container, reusable and observable sequence.
    ///
    /// - Parameter transformer: A closure with params of the original container, reusable and observable sequence, retuning an instance of new observable sequence.
    /// - Returns: A new `Events` instance from transformer closure's result. it keep same `C` and `R` with the original `Events` instance.
    public func with<U : ObservableConvertibleType>(_ transformer: @escaping (C, R, O) -> U) -> Events<C, R, U> {
        let newObs: Observable<(R, U)> = obs.map { (values) -> (R, U) in
            return (values.0, transformer(self.container, values.0, values.1))
        }
        
        var events = Events<C, R, U>(newObs)
        events.container = container
        return events
    }
    
    /// Catch error that is on reusable.
    public func catchEventsError(_ errorHandler: @escaping (Error) -> Observable<O.E>) -> Events<C, R, Observable<O.E>> {
        return with { (container, reusable, observable) -> Observable<O.E> in
            observable.asObservable()
                .catchError({ (error) -> Observable<O.E> in
                    return errorHandler(error)
                })
                .do(onError: { (error) in
                    fatalError(error.localizedDescription)
                })
        }
    }
    
    private func flatten(_ errorHandler: ((Error) -> Observable<O.E>)? = nil) -> Observable<O.E> {
        return flatten(with: { $2 }, errorHandler)
    }
    
    private func flatten<T>(with extra: @escaping (C, R, O.E) -> T,
                           _ errorHandler: ((Error) -> Observable<O.E>)? = nil) -> Observable<T> {
        return obs.flatMap({ (values) -> Observable<T> in
            values.1.asObservable()
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


public extension Events where R : Indexed, C : IndexedContainer, R.IndexedType == C.IndexedType {
    
    func withIndexPath<T>(_ carried: @escaping (O.E, IndexPath?) -> T) -> Events<C, R, Observable<T>> {
        return with { (container, reusable, observable) -> Observable<T> in
            observable.asObservable()
                .map { (e) -> T in
                    carried(e, container.indexPath(for: reusable as! C.IndexedType))
            }
        }
    }
    
}

public extension Events where R : Indexed, C : ModelIndexedContainer, R.IndexedType == C.IndexedType {
    func withModel<T, M>(with modelType: M.Type, _ carried: @escaping (O.E, M?) -> T) -> Events<C, R, Observable<T>> {
        return with { (container, reusable, observable) -> Observable<T> in
            observable.asObservable()
                .map { (e) -> T in
                    if let indexPath = container.indexPath(for: reusable as! C.IndexedType) {
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
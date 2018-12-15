//
//  Events.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation
import RxSwift

/// Represents an observable sequence that comes from flattening all observable sequence on reusables.
/// An `Events` instance should not fail, so please make sure that you catched all the errors on reusable.
public struct Events<C : ReusableContainer, R : ReusableObject, O : ObservableConvertibleType> {
    
    enum EventsError : String, Error {
        case unhandleError = "An unhandled error"
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
            (values.0, transformer(self.container, values.0, values.1))
        }
        
        var events = Events<C, R, U>(newObs)
        events.container = container
        return events
    }
    
    /// Catch error that is on reusable.
    public func catchEventsError(_ errorHandler: @escaping (Error) -> Observable<O.E>) -> Events<C, R, Observable<O.E>> {
        return with { (container, reusable, observable) -> Observable<O.E> in
            observable.asObservable()
                .catchError(errorHandler)
                .do(onError: { fatalError($0.localizedDescription) })
        }
    }
    
    private func flatten(_ errorHandler: @escaping (Error) -> Observable<O.E> = Observable.error) -> Observable<O.E> {
        return flatten(with: { $2 }, errorHandler)
    }
    
    private func flatten<T>(with extra: @escaping (C, R, O.E) -> T,
                            _ errorHandler: @escaping (Error) -> Observable<O.E>) -> Observable<T> {
        
        return obs.flatMap { (values) -> Observable<T> in
            values.1.asObservable()
                .catchError(errorHandler)
                .do(onError: { fatalError($0.localizedDescription) })
                .map(curry(extra)(self.container)(values.0))
        }
        
    }
}


public extension Events where R : Indexed, C : IndexedContainer, R.IndexedType == C.IndexedType {
    
    func withIndexPath<T>(_ carried: @escaping (IndexPath?, O.E) -> T) -> Events<C, R, Observable<T>> {
        return with { (container, reusable, observable) -> Observable<T> in
            observable.asObservable()
                .map { carried(container.indexPath(for: reusable as! C.IndexedType), $0) }
        }
    }
    
    func withIndexPath() -> Events<C, R, Observable<(IndexPath?, O.E)>> {
        return withIndexPath { ($0, $1) }
    }
    
}

public extension Events where R : Indexed, C : ModelIndexedContainer, R.IndexedType == C.IndexedType {
    
    /// Create a new Events instance with model from the Reusable
    /// The result could emit an Error event which is from ModelIndexedContainer.model<T>(at:) throws -> T
    ///
    /// - Parameters:
    ///   - modelType: The model's type
    ///   - carried: A transfromer from model to the value you wanna
    /// - Returns: A new Events instance with new type T
    func withModel<T, M>(with modelType: M.Type, _ carried: @escaping ( M?, O.E) -> T) -> Events<C, R, Observable<T>> {
        return with { (container, reusable, observable) -> Observable<T> in
            observable.asObservable()
                .flatMap { (e) -> Observable<T> in
                    if let indexPath = container.indexPath(for: reusable as! C.IndexedType) {
                        do {
                            let model: M = try container.model(at: indexPath)
                            return Observable.just(carried(model, e))
                        } catch let error {
                            return Observable.error(error)
                        }
                    }
                    return Observable.just(carried(nil, e))
                }
        }
    }
    
    public func withModel<M>(with modelType: M.Type) -> Events<C, R, Observable<(M?, O.E)>> {
        return withModel(with: modelType, { ($0, $1) })
    }
    
}

extension Events: ObservableType {
    public typealias E = O.E
    
    public func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, Events.E == O.E {
        return flatten().subscribe(observer)
    }
}

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
public struct Events<Container : ReusableContainerType, ReusableObject : ReusableObjectType, ObservableConvertible : ObservableConvertibleType> {
    
    enum EventsError : String, Error {
        case unhandleError = "An unhandled error"
    }
    
    weak var container: Container!
    
    private let obs: Observable<(ReusableObject, ObservableConvertible)>
    
    init(_ obs: Observable<(ReusableObject, ObservableConvertible)>) {
        self.obs = obs
    }
    
    /// Create a new Event instance from the original container, reusable and observable sequence.
    ///
    /// - Parameter transformer: A closure with params of the original container, reusable and observable sequence, retuning an instance of new observable sequence.
    /// - Returns: A new `Events` instance from transformer closure's result. it keep same `C` and `R` with the original `Events` instance.
    public func with<U : ObservableConvertibleType>(_ transformer: @escaping (Container, ReusableObject, ObservableConvertible) -> U) -> Events<Container, ReusableObject, U> {
        
        let newObs: Observable<(ReusableObject, U)> = obs.map { (values) -> (ReusableObject, U) in
            return (values.0, transformer(self.container, values.0, values.1))
        }
        
        var events = Events<Container, ReusableObject, U>(newObs)
        events.container = container
        return events
    }
    
    /// Catch error that is on reusable.
    public func catchEventsError(_ errorHandler: @escaping (Error) -> Observable<ObservableConvertible.Element>) -> Events<Container, ReusableObject, Observable<ObservableConvertible.Element>> {
        return with { (container, reusable, observable) -> Observable<ObservableConvertible.Element> in
            observable.asObservable()
                .catchError({ (error) -> Observable<ObservableConvertible.Element> in
                    return errorHandler(error)
                })
                .do(onError: { (error) in
                    fatalError(error.localizedDescription)
                })
        }
    }
    
    private func flatten(_ errorHandler: ((Error) -> Observable<ObservableConvertible.Element>)? = nil) -> Observable<ObservableConvertible.Element> {
        return flatten(with: { $2 }, errorHandler)
    }
    
    private func flatten<T>(with extra: @escaping (Container, ReusableObject, ObservableConvertible.Element) -> T,
                           _ errorHandler: ((Error) -> Observable<ObservableConvertible.Element>)? = nil) -> Observable<T> {
        return obs.flatMap({ (values) -> Observable<T> in
            values.1.asObservable()
                .catchError({ (error) -> Observable<ObservableConvertible.Element> in
                    return errorHandler?(error) ?? Observable.error(error)
                })
                .do(onError: { (error) in
                    fatalError(error.localizedDescription)
                })
                .map{ extra(self.container, values.0, $0) }
        })
    }
}


public extension Events where ReusableObject : IndexedType, Container : IndexedContainerType, ReusableObject.Indexed == Container.Indexed {
    
    func withIndexPath<T>(_ carried: @escaping (IndexPath?, ObservableConvertible.Element) -> T) -> Events<Container, ReusableObject, Observable<T>> {
        return with { (container, reusable, observable) -> Observable<T> in
            observable.asObservable()
                .map { (e) -> T in
                    carried(container.indexPath(for: reusable as! Container.Indexed), e)
            }
        }
    }
    
    func withIndexPath() -> Events<Container, ReusableObject, Observable<(IndexPath?, ObservableConvertible.Element)>> {
        return withIndexPath { (indexPath: $0, element: $1) }
    }
    
}

public extension Events where ReusableObject : IndexedType, Container : ModelIndexedContainer, ReusableObject.Indexed == Container.Indexed {
    
    /// Create a new Events instance with model from the Reusable
    /// The result could emit an Error event which is from ModelIndexedContainer.model<T>(at:) throws -> T
    ///
    /// - Parameters:
    ///   - modelType: The model's type
    ///   - carried: A transfromer from model to the value you wanna
    /// - Returns: A new Events instance with new type T
    func withModel<T, M>(with modelType: M.Type, _ carried: @escaping (M?, ObservableConvertible.Element) -> T) -> Events<Container, ReusableObject, Observable<T>> {
        return with { (container, reusable, observable) -> Observable<T> in
            observable.asObservable()
                .flatMap { (e) -> Observable<T> in
                    if let indexPath = container.indexPath(for: reusable as! Container.Indexed) {
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
    
    func withModel<M>(with modelType: M.Type) -> Events<Container, ReusableObject, Observable<(M?, ObservableConvertible.Element)>> {
        return withModel(with: modelType, { (model: $0, element: $1) })
    }
    
}

extension Events : ObservableType {
    
    public typealias Element = ObservableConvertible.Element
    
    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Events.Element == Observer.Element {
        return flatten().subscribe(observer)
    }

}

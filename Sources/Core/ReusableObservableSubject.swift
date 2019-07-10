//
//  ReusableObservableSubject.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation
import RxSwift

class ReusableObservableSubject<Container : ReusableContainerType, ObservableConvertible> : SubjectType {
    
    typealias Element = (NSObject, ObservableConvertible)
    typealias Observer = AnyObserver<Element>
    
    private let targetSubject: ReplaySubject<Element> = ReplaySubject<Element>.createUnbounded()
    
    private let toObservableConvertible: (NSObject) -> ObservableConvertible
    
    init(_ toObservableConvertible: @escaping (NSObject) -> ObservableConvertible) {
        self.toObservableConvertible = toObservableConvertible
    }
    
    func emitReusableObservable(on reusable: NSObject) {
        targetSubject.onNext((reusable, toObservableConvertible(reusable)))
    }
    
    func emitReusableObservables(on reusables: AnyCollection<NSObject>) {
        reusables.forEach(emitReusableObservable)
    }
    
    func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, ReusableObservableSubject.Element == Observer.Element {
        return targetSubject.subscribe(observer)
    }
    
    func asObserver() -> ReusableObservableSubject<Container, ObservableConvertible>.Observer {
        return AnyObserver(targetSubject)
    }
    
    deinit {
        targetSubject.onCompleted()
    }
    
}

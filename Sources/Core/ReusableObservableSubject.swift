//
//  ReusableObservableSubject.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation
import RxSwift

class ReusableObservableSubject<C : ReusableContainer, ObservableConvertible> : SubjectType {
    
    typealias E = (NSObject, ObservableConvertible)
    typealias SubjectObserverType = AnyObserver<E>
    
    private let targetSubject: ReplaySubject<E> = ReplaySubject<E>.createUnbounded()
    
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
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, ReusableObservableSubject.E == O.E {
        return targetSubject.subscribe(observer)
    }
    
    func asObserver() -> ReusableObservableSubject<C, ObservableConvertible>.SubjectObserverType {
        return AnyObserver(targetSubject)
    }
    
    deinit {
        targetSubject.onCompleted()
    }
    
}

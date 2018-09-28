//
//  ElementSequence.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import UIKit
import RxSwift


class ViewObservableSubject<C : ReusableViewContainer, ObservableConvertible> : SubjectType {
    
    typealias E = (UIView, ObservableConvertible)
    typealias SubjectObserverType = AnyObserver<E>
    
    private let targetSubject: ReplaySubject<E> = ReplaySubject<E>.createUnbounded()
    private let toObservableConvertible: (UIView) -> ObservableConvertible
    
    init(_ toObservableConvertible: @escaping (UIView) -> ObservableConvertible) {
        self.toObservableConvertible = toObservableConvertible
    }
    
    func emitViewObservable(on reusableView: UIView) {
        targetSubject.onNext((reusableView, toObservableConvertible(reusableView)))
    }
    
    func emitViewObservables(on reusableViews: AnyCollection<UIView>) {
        reusableViews.forEach(emitViewObservable)
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, ViewObservableSubject.E == O.E {
        return targetSubject.subscribe(observer)
    }
    
    func asObserver() -> ViewObservableSubject<C, ObservableConvertible>.SubjectObserverType {
        return AnyObserver(targetSubject)
    }
    
    deinit {
        targetSubject.onCompleted()
    }
    
}

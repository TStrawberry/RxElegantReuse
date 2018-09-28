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
    
    private let targetObs: ReplaySubject<E> = ReplaySubject<E>.createUnbounded()
    private let toElement: (UIView) -> ObservableConvertible
    
    init(_ toElement: @escaping (UIView) -> ObservableConvertible) {
        self.toElement = toElement
    }
    
    func emitElement(on reusableView: UIView) {
        targetObs.onNext((reusableView, toElement(reusableView)))
    }
    
    func emitElement(on reusableViews: AnyCollection<UIView>) {
        reusableViews.forEach(emitElement)
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, ViewObservableSubject.E == O.E {
        return targetObs.subscribe(observer)
    }
    
    func on(_ event: Event<(UIView, ObservableConvertible)>) {
        targetObs.on(event)
    }
    
    func asObserver() -> ViewObservableSubject<C, ObservableConvertible>.SubjectObserverType {
        return AnyObserver(targetObs)
    }
    
    deinit {
        targetObs.onCompleted()
    }
    
}

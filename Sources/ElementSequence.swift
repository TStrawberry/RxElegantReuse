//
//  ElementSequence.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import UIKit
import RxSwift


class ElementSequence<C : ReusableViewContainer, Element> : ObservableType, ObserverType {
    
    typealias E = (UIView, Element)
    
    private let targetObs: ReplaySubject<E> = ReplaySubject<E>.createUnbounded()
    private let toElement: (UIView) -> Element
    
    init(_ toElement: @escaping (UIView) -> Element) {
        self.toElement = toElement
    }
    
    func emitElement(on reusableView: UIView) {
        targetObs.onNext((reusableView, toElement(reusableView)))
    }
    
    func emitElement(on reusableViews: AnyCollection<UIView>) {
        reusableViews.forEach(emitElement)
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, ElementSequence.E == O.E {
        return targetObs.subscribe(observer)
    }
    
    func on(_ event: Event<(UIView, Element)>) {
        targetObs.on(event)
    }
    
    deinit {
        targetObs.onCompleted()
    }
    
}

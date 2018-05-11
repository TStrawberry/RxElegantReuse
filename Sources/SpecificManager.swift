//
//  SpecificManager.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import UIKit
import RxSwift


typealias ViewSet = NSHashTable<UIView>

class SpecificManager<C : ReusableViewContainer> {
    
    private lazy var elementSequences   : [AnyKeyPath: ElementSequence<C, Any>]     = { return [:] }()
    private lazy var subClassManager    : [InheritPath: SpecificManager<C>]         = { return [:] }()
    private lazy var views              : ViewSet    = { return ViewSet(options: .weakMemory) }()
    
    func add<R : ReusableView>(_ reusableView: R, with path: InheritPath) {
        
        if let subInheritPath = path.subInheritPath {
            subManager(for: subInheritPath).add(reusableView, with: subInheritPath)
        } else {
            views.add(reusableView)
        }
        
        elementSequences.values.forEach { $0.emitElement(on: reusableView) }
    }
    
    
    func events<R : ReusableView, O : ObservableConvertibleType>(for keyPath: KeyPath<R, O>, inheritPath: InheritPath) -> Events<C, R, O> {
        
        if let subInheritPath = inheritPath.subInheritPath {
            return subManager(for: subInheritPath).events(for: keyPath, inheritPath: subInheritPath)
        }
        
        return Events<C, R, O>(
            elementSequence(for: keyPath)
                .mapFilterNil({ (values) -> (R, O)? in
                    return values ?>> (R, O).self
                }))
    }
    
    
    private func subManager(for inheritPath: InheritPath) -> SpecificManager<C> {
        if let subManager = subClassManager[inheritPath] { return subManager }

        let subManager = SpecificManager<C>()
        subClassManager[inheritPath] = subManager
        return subManager
    }
    
    
    private func elementSequence<R : ReusableView, O>(for keyPath: KeyPath<R, O>) -> ElementSequence<C, Any> {
        
        if let elementSequence = elementSequences[keyPath] { return elementSequence }
        
        let elementSequence = ElementSequence<C, Any> { $0[keyPath: keyPath] }
        elementSequence.emitElement(on: AnyCollection(views.allObjects))
        _ = subClassManager.values
            .map { $0.elementSequence(for: keyPath) }
            .merge()?
            .mapFilterNil {
                (values) -> (R, O)? in values ?>> (R, O).self
            }
            .bind(to: elementSequence)
        
        elementSequences[keyPath] = elementSequence
        return elementSequence
        
    }
    
}

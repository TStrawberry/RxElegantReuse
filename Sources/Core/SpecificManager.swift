//
//  SpecificManager.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import Foundation
import RxSwift

typealias ObjectSet = NSHashTable<NSObject>

class SpecificManager<C : ReusableContainer> {
    
    private lazy var reusableObservableSubjects: [AnyKeyPath: ReusableObservableSubject<C, Any>] = { return [:] }()
    private lazy var subClassManager: [InheritPath: SpecificManager<C>] = { return [:] }()
    private lazy var objects: ObjectSet = { return ObjectSet(options: .weakMemory) }()
    
    func add<R : ReusableObject>(_ reusableObject: R, with path: InheritPath) {
        
        if let subInheritPath = path.subInheritPath {
            
            subManager(for: subInheritPath).add(reusableObject, with: subInheritPath)
        } else {
            objects.add(reusableObject)
        }
        
        reusableObservableSubjects.values.forEach { $0.emitReusableObservable(on: reusableObject) }
    }
    
    func events<R : ReusableObject, O : ObservableConvertibleType>(for keyPath: KeyPath<R, O>, inheritPath: InheritPath) -> Events<C, R, O> {
        
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
    
    private func elementSequence<R : ReusableObject, O>(for keyPath: KeyPath<R, O>) -> ReusableObservableSubject<C, Any> {
        
        if let reusableObservableSubject = reusableObservableSubjects[keyPath] { return reusableObservableSubject }
        
        let viewObservableSubject = ReusableObservableSubject<C, Any> { ($0 as! R)[keyPath: keyPath] }
        viewObservableSubject.emitReusableObservables(on: AnyCollection(objects.allObjects))
        _ = subClassManager.values
            .map { $0.elementSequence(for: keyPath) }
            .merge()?
            .mapFilterNil {
                (values) -> (R, O)? in values ?>> (R, O).self
            }
            .subscribe(viewObservableSubject.asObserver())
        
        reusableObservableSubjects[keyPath] = viewObservableSubject
        return viewObservableSubject
    }
    
}


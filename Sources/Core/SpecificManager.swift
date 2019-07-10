//
//  SpecificManager.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation
import RxSwift

typealias ObjectSet = NSHashTable<NSObject>

class SpecificManager<Container : ReusableContainerType> {
    
    private lazy var reusableObservableSubjects: [AnyKeyPath: ReusableObservableSubject<Container, Any>] = { return [:] }()
    private lazy var subClassManager: [InheritPath: SpecificManager<Container>] = { return [:] }()
    private lazy var objects: ObjectSet = { return ObjectSet(options: .weakMemory) }()
    
    func add<R : ReusableObjectType>(_ reusableObject: R, with path: InheritPath) {
        
        if let subInheritPath = path.subInheritPath {
            
            subManager(for: subInheritPath).add(reusableObject, with: subInheritPath)
        } else {
            objects.add(reusableObject)
        }
        
        reusableObservableSubjects.values.forEach { $0.emitReusableObservable(on: reusableObject) }
    }
    
    func events<ReusableObject : ReusableObjectType, ObservableConvertible : ObservableConvertibleType>(for keyPath: KeyPath<ReusableObject, ObservableConvertible>, inheritPath: InheritPath) -> Events<Container, ReusableObject, ObservableConvertible> {
        
        if let subInheritPath = inheritPath.subInheritPath {
            return subManager(for: subInheritPath).events(for: keyPath, inheritPath: subInheritPath)
        }
        
        return Events<Container, ReusableObject, ObservableConvertible>(
            elementSequence(for: keyPath)
                .mapFilterNil({ (values) -> (ReusableObject, ObservableConvertible)? in
                    return values ?>> (ReusableObject, ObservableConvertible).self
                }))
    }
    
    
    private func subManager(for inheritPath: InheritPath) -> SpecificManager<Container> {
        if let subManager = subClassManager[inheritPath] { return subManager }

        let subManager = SpecificManager<Container>()
        subClassManager[inheritPath] = subManager
        return subManager
    }
    
    private func elementSequence<ReusableObject : ReusableObjectType, ObservableConvertible: ObservableConvertibleType>(for keyPath: KeyPath<ReusableObject, ObservableConvertible>) -> ReusableObservableSubject<Container, Any> {
        
        if let reusableObservableSubject = reusableObservableSubjects[keyPath] { return reusableObservableSubject }
        
        let reusableObservableSubject = ReusableObservableSubject<Container, Any> { ($0 as! ReusableObject)[keyPath: keyPath] }
        reusableObservableSubject.emitReusableObservables(on: AnyCollection(objects.allObjects))
        _ = subClassManager.values
            .map { $0.elementSequence(for: keyPath) }
            .merge()?
            .mapFilterNil {
                (values) -> (ReusableObject, ObservableConvertible)? in values ?>> (ReusableObject, ObservableConvertible).self
            }
            .subscribe(reusableObservableSubject.asObserver())
        
        reusableObservableSubjects[keyPath] = reusableObservableSubject
        return reusableObservableSubject
    }
    
}


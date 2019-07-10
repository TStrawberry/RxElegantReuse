//
//  ElegantEventsManager.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation
import RxSwift

class ElegantEventsManager<Container : ReusableContainerType> {
    
    private var specificManagers : [InheritPath: Any] = [:]
    private var reusableObjects : ObjectSet = ObjectSet(options: .weakMemory)
    
    func add<ReusableObject : ReusableObjectType>(_ reusableObject: ReusableObject) {
        if reusableObjects.contains(reusableObject) { return }
        reusableObjects.add(reusableObject)
        
        let inheritPath = try! InheritPath.instance(from: type(of: reusableObject), to: ReusableObject.BaseReusable.self)
        specificManager(for: inheritPath).add(reusableObject, with: inheritPath)
    }
    
    func events<ReusableObject : ReusableObjectType, ObservableConvertible : ObservableConvertibleType>(for keyPath: KeyPath<ReusableObject, ObservableConvertible>) -> Events<Container, ReusableObject, ObservableConvertible> {
        let inheritPath = try! InheritPath.instance(from: ReusableObject.self, to: ReusableObject.BaseReusable.self)
        return specificManager(for: inheritPath)
            .events(for: keyPath, inheritPath: inheritPath)
    }
    
    private func specificManager(`for` inheritPath: InheritPath) -> SpecificManager<Container> {
        if let spec = specificManagers[inheritPath] as? SpecificManager<Container> {
            return spec
        } else {
            let spec = SpecificManager<Container>()
            specificManagers[inheritPath] = spec
            return spec
        }
    }
    
}

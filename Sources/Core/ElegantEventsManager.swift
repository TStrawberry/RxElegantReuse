//
//  ElegantEventsManager.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import Foundation
import RxSwift

class ElegantEventsManager<C : ReusableContainer> {
    
    private var specificManagers : [InheritPath: Any] = [:]
    private var reusableObjects : ObjectSet = ObjectSet(options: .weakMemory)
    
    func add<R : ReusableObject>(_ reusableObject: R) {
        if reusableObjects.contains(reusableObject) { return }
        reusableObjects.add(reusableObject)
        
        let inheritPath = try! InheritPath.instance(from: type(of: reusableObject), to: R.BaseReusableType.self)
        specificManager(for: inheritPath).add(reusableObject, with: inheritPath)
    }
    
    func events<R : ReusableObject, O : ObservableConvertibleType>(for keyPath: KeyPath<R, O>) -> Events<C, R, O> {
        let inheritPath = try! InheritPath.instance(from: R.self, to: R.BaseReusableType.self)
        return specificManager(for: inheritPath)
            .events(for: keyPath, inheritPath: inheritPath)
    }
    
    private func specificManager(`for` inheritPath: InheritPath) -> SpecificManager<C> {
        if let spec = specificManagers[inheritPath] as? SpecificManager<C> {
            return spec
        } else {
            let spec = SpecificManager<C>()
            specificManagers[inheritPath] = spec
            return spec
        }
    }
    
}

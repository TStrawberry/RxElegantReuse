//
//  ElegantEventsManager.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import UIKit
import RxSwift

class ElegantEventsManager<C : UIView & ReusableViewContainer> {
    
    private var specificManagers : [InheritPath: Any] = [:]
    private var views : ViewSet = ViewSet(options: .weakMemory)
    
    func add<R : ReusableView>(_ reusableView: R) {
        if views.contains(reusableView) { return }
        views.add(reusableView)
        
        let inheritPath = try! InheritPath.instance(from: type(of: reusableView), to: R.BaseReusableViewType.self)
        specificManager(for: inheritPath).add(reusableView, with: inheritPath)
    }
    
    func events<R : ReusableView, O : ObservableConvertibleType>(for keyPath: KeyPath<R, O>) -> Events<C, R, O> {
        let inheritPath = try! InheritPath.instance(from: R.self, to: R.BaseReusableViewType.self)
        return specificManager(for: inheritPath).events(for: keyPath, inheritPath: inheritPath)
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

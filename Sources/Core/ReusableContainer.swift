//
//  ReusableContainer.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import Foundation
import RxSwift

public protocol ReusableContainer : NSObjectProtocol { }

public protocol IndexedContainer : ReusableContainer {
    
    associatedtype IndexedType: IndexedObject
    
    func indexPath(for cell: IndexedType) -> IndexPath?
}

public protocol ModelIndexedContainer : IndexedContainer {
    
    func model<T>(at indexPath: IndexPath) throws -> T
}



fileprivate var elegantEventsManagerContext: UInt8 = 0

extension ReusableContainer {
    
    var elegantManager: ElegantEventsManager<Self> {
        
        get {
            if let elegantMgr = objc_getAssociatedObject(self, &elegantEventsManagerContext) as? ElegantEventsManager<Self> {
                return elegantMgr
            }
            let elegantMgr = ElegantEventsManager<Self>()
            objc_setAssociatedObject(self, &elegantEventsManagerContext, elegantMgr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return elegantMgr
        }
        
        set {
            objc_setAssociatedObject(self, &elegantEventsManagerContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func add<R : ReusableObject>(_ reusableObject: R) {
        elegantManager.add(reusableObject)
    }
    
}


public extension Reactive where Base : ReusableContainer {
    
    func events<R : ReusableObject, O : ObservableConvertibleType>(_ keyPath : KeyPath<R, O>) -> Events<Base, R, O> {
        debugOnly { MainScheduler.ensureExecutingOnScheduler() }
        var events = base.elegantManager.events(for: keyPath)
        events.container = base
        return events
    }

}



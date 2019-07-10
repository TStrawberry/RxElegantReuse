//
//  ReusableContainer.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation
import RxSwift

public protocol ReusableContainerType : NSObjectProtocol { }

public protocol IndexedContainerType : ReusableContainerType {
    
    associatedtype Indexed: IndexedObjectType
    
    func indexPath(for cell: Indexed) -> IndexPath?
}

public protocol ModelIndexedContainer : IndexedContainerType {
    
    func model<T>(at indexPath: IndexPath) throws -> T
}



fileprivate var elegantEventsManagerContext: UInt8 = 0

extension ReusableContainerType {
    
    var elegantManager: ElegantEventsManager<Self> {
        
        if let elegantMgr = objc_getAssociatedObject(self, &elegantEventsManagerContext) as? ElegantEventsManager<Self> {
            return elegantMgr
        }
        let elegantMgr = ElegantEventsManager<Self>()
        objc_setAssociatedObject(self, &elegantEventsManagerContext, elegantMgr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return elegantMgr
    }
    
    func add<ReusableObject : ReusableObjectType>(_ reusableObject: ReusableObject) {
        elegantManager.add(reusableObject)
    }
    
}


public extension Reactive where Base : ReusableContainerType {
    
    func events<ReusableObject : ReusableObjectType, ObservableConvertible : ObservableConvertibleType>(_ keyPath : KeyPath<ReusableObject, ObservableConvertible>) -> Events<Base, ReusableObject, ObservableConvertible> {
        debugOnly { MainScheduler.ensureExecutingOnScheduler() }
        var events = base.elegantManager.events(for: keyPath)
        events.container = base
        return events
    }

}



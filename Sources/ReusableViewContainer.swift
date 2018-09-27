//
//  ReusableViewContainer.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import UIKit
import RxSwift
import RxCocoa

public protocol ReusableViewContainer : NSObjectProtocol {
    
    associatedtype IndexedType: IndexedView
    
    func indexPath(for cell: IndexedType) -> IndexPath?
    
    func model<T>(at indexPath: IndexPath) throws -> T
}

extension UITableView : ReusableViewContainer {
    
    public typealias IndexedType = UITableViewCell
    
    public func model<T>(at indexPath: IndexPath) throws -> T {
        return try rx.model(at: indexPath)
    }
}

extension UICollectionView : ReusableViewContainer {
    
    public typealias IndexedType = UICollectionViewCell
    
    public func model<T>(at indexPath: IndexPath) throws -> T {
        return try rx.model(at: indexPath)
    }
    
}

fileprivate var elegantEventsManagerContext: UInt8 = 0

extension ReusableViewContainer where Self : UIScrollView {
    
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
    
    func add<R : ReusableView>(_ view: R) {
        elegantManager.add(view)
    }
    
}


public extension Reactive where Base : UIScrollView & ReusableViewContainer {
    
    func events<R : ReusableView, O : ObservableConvertibleType>(_ keyPath : KeyPath<R, O>) -> Events<Base, R, O> {
        #if DEBUG
            MainScheduler.ensureExecutingOnScheduler()
        #endif
        var events = base.elegantManager.events(for: keyPath)
        events.container = base
        return events
    }

}



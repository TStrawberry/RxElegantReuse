//
//  Reusable.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import Foundation

public protocol Reusable : NSObjectProtocol {
    associatedtype BaseReusableType : NSObject
}

public protocol Indexed : Reusable {
    associatedtype IndexedType : NSObject
}


public typealias ReusableObject = NSObject & Reusable
public typealias IndexedObject = ReusableObject & Indexed

public extension Reusable where Self : NSObject {
    @discardableResult
    func managed<T : ReusableContainer>(by container: T?) -> Self {
        container?.add(self)
        return self
    }
}

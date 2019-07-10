//
//  Reusable.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation

public protocol ReusableType : NSObjectProtocol {
    associatedtype BaseReusable : NSObject
    associatedtype Container : ReusableContainerType
}

public protocol IndexedType : ReusableType {
    associatedtype Indexed : NSObject
}

public typealias ReusableObjectType = NSObject & ReusableType
public typealias IndexedObjectType = ReusableObjectType & IndexedType

public extension ReusableType where Self : NSObject {
    @discardableResult
    func managed(by container: Container?) -> Self {
        container?.add(self)
        return self
    }
}

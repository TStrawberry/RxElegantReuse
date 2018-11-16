//
//  InheritPath.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation

enum InheritPath : Hashable {
    
    case end
    
    indirect case path(ObjectIdentifier, InheritPath)
    
    enum InitError : Error, CustomDebugStringConvertible {
        
        case notExist(sub: AnyClass, sup: AnyClass)
        
        var debugDescription: String {
            switch self {
            case let .notExist(sub, sup):
                return "\(sub) does not inherit from \(sup)"
            }
        }
    }
    
    var subInheritPath: InheritPath? {
        if case InheritPath.path(_, let path) = self,
            case InheritPath.path(_, .path) = path {
            return path
        } else {
            return nil
        }
    }
    
    static func instance(from sub: AnyClass, to sup: AnyClass, with path: InheritPath = .end) throws -> InheritPath {
        
        guard let superClass = sub.superclass() else { throw InitError.notExist(sub: sub, sup: sub) }
        if sub == sup { return path }
        
        let newPath = InheritPath.path(ObjectIdentifier(sub), path)
        return try instance(from: superClass, to: sup, with: newPath)
    }
}

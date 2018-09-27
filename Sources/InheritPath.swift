//
//  InheritPath.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import Foundation


class InheritPath : Hashable {
    
    enum InitError : Error {
        case notExist
    }
    
    let subInheritPath: InheritPath?
    var hashValue: Int { return identifier.hashValue }
    
    private let identifier: ObjectIdentifier
    
    init(_ identifier: ObjectIdentifier, _ subInheritPath: InheritPath? = nil) {
        self.identifier = identifier
        self.subInheritPath = subInheritPath
    }
    
    static func instance(from sub: AnyClass, to sup: AnyClass, with path: InheritPath? = nil) throws -> InheritPath {
        guard let superClass = sub.superclass() else { throw InitError.notExist }
        
        if sub == sup {
            if let `path` = path {
                return `path`
            } else {
                throw InitError.notExist
            }
        }
        
        let newPath = InheritPath(ObjectIdentifier(sub), path)
        return try instance(from: superClass, to: sup, with: newPath)
    }
    
    static func ==(lhs: InheritPath, rhs: InheritPath) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}




//
//  Catch.swift
//  RxElegantReuse
//
//  Created by Todd on 2018/12/15.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation

typealias Throwable<T> = () throws -> T

enum Catch<T> {
    
    case throwable(Throwable<T>)
    
    case error(Error)
    
    func value() throws -> T {
        
        switch self {
        case let .throwable(throwable):
            do {
                return try throwable()
            } catch let error {
                throw error
            }
            
        case let .error(error):
            throw error
        }
    }
    
    
    func map<R>(_ transform: @escaping (T) throws -> R) -> Catch<R> {
        switch self {
        case let .throwable(thowable):
            do {
                let t = try thowable()
                return Catch<R>.throwable { try transform(t) }
            } catch let error {
                return Catch<R>.error(error)
            }
            
        case let .error(e):
            return Catch<R>.error(e)
        }
    }
    
    func apply<R>(_ mapper: Catch<(T) -> R>) -> Catch<R> {
        switch mapper {
        case .throwable(let throwable):
            do {
                return map(try throwable())
            } catch let error {
                return Catch<R>.error(error)
            }
            
        case .error(let error):
            return Catch<R>.error(error)
        }
    }
    
    func flatMap<R>(_ transform: (T) -> Catch<R>) -> Catch<R> {
        switch self {
        case let .throwable(thowable):
            do {
                let t = try thowable()
                return transform(t)
            } catch let error {
                return Catch<R>.error(error)
            }
            
        case let .error(e):
            return Catch<R>.error(e)
        }
    }
    
}

func `catch`<T>(_ throwable: @autoclosure @escaping () throws -> T) -> Catch<T> {
    return Catch.throwable(throwable)
}

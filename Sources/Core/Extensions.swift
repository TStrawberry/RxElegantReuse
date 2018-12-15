//
//  Extensions.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import Foundation
import RxSwift

// Originally from here: https://github.com/artsy/eidolon/blob/24e36a69bbafb4ef6dbe4d98b575ceb4e1d8345f/Kiosk/Observable%2BOperators.swift#L30-L40
protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional : OptionalType {
    var value: Wrapped? {
        return self
    }
}

// Originally from here: https://github.com/RxSwiftCommunity/RxOptional/blob/master/Source/Observable%2BOptional.swift#L8-L21
extension ObservableType where E : OptionalType {
    func filterNil() -> Observable<E.Wrapped> {
        
        return self.flatMap { element -> Observable<E.Wrapped> in
            guard let value = element.value else {
                return Observable<E.Wrapped>.empty()
            }
            return Observable<E.Wrapped>.just(value)
        }
    }
}

// Originally from here: https://github.com/vapor/vapor/blob/74a46ecacca51d326a1e8cf4b7967827765f05bf/Sources/Vapor/Error/Error.swift#L66-L68
func debugOnly(_ body: () -> Void) {
    assert({ body(); return true }())
}


// Originally from here: https://github.com/thoughtbot/Curry/blob/master/Source/Curry.swift#L1-L11
func curry<A, B>(_ function: @escaping (A) -> B) -> (A) -> B {
    return { (a: A) -> B in function(a) }
}

func curry<A, B, C>(_ function: @escaping ((A, B)) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function((a, b)) } }
}

func curry<A, B, C, D>(_ function: @escaping ((A, B, C)) -> D) -> (A) -> (B) -> (C) -> D {
    return { (a: A) -> (B) -> (C) -> D in { (b: B) -> (C) -> D in { (c: C) -> D in function((a, b, c)) } } }
}



func inversedCurry<A, B, C>(_ function: @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return { (a: A, b: B) -> C in function(a)(b) }
}

func inversedCurry<A, B, C, D>(_ function: @escaping (A) -> (B) -> (C) -> D) -> (A, B, C) -> D {
    return { (a: A, b: B, c: C) -> D in function(a)(b)(c) }
}






precedencegroup TupleTransfromPrecedence {
    associativity: left
}

infix operator ?>> : TupleTransfromPrecedence

func ?>> <A1, B1, A2, B2>(tuple: (A1, B1), type: (A2, B2).Type) -> (A2, B2)? {
    if let a2 = tuple.0 as? A2,
        let b2 = tuple.1 as? B2 {
        return (a2, b2)
    }
    return nil
}

extension ObservableType {
    func mapFilterNil<T>(_ selector: @escaping (E) -> T?) -> Observable<T> {
        return map(selector).filterNil()
    }
}

extension Array where Element: ObservableType {
    func merge() -> Observable<Element.E>? {
        guard count > 0 else { return nil }
        return Observable.merge(map{ $0.asObservable() })
    }
}



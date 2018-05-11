//
//  Extensions.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
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



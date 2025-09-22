//
//  ArrayExtension.swift
//  Predicate
//
//  Created by Eden on 2025/9/22.
//

import Foundation

public
extension Array
{
    func filter<Value>(by predicate: Predicate<Element, Value>) -> Array<Element>
    {
        self.filter({ predicate.evaluate(with: $0) })
    }
    
    func filter<Predicate>(by predicate: Predicate) -> Array<Element> where Predicate: CompoundPredicate, Predicate.Root == Element
    {
        self.filter({ predicate.evaluate(with: $0) })
    }
}

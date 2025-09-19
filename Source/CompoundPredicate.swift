//
//  CompoundPredicate.swift
//  Predicate
//
//  Created by Eden on 2025/9/19.
//

import Foundation

public
protocol CompoundPredicate
{
    associatedtype Root
    
    var nsPredicate: NSPredicate { get }
    
    init(target: any CompoundPredicate)
    
    func evaluate(with object: Root) -> Bool
}

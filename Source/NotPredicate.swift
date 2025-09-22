//
//  NotPredicate.swift
//  Predicate
//
//  Created by Darktt on 2025/9/19.
//

import Foundation

public
struct NotPredicate<Root>: CompoundPredicate
{
    // MARK: - Properties -
    
    private
    let subpredicate: NSPredicate
    
    public
    var nsPredicate: NSPredicate {
        
        NSCompoundPredicate(notPredicateWithSubpredicate: self.subpredicate)
    }
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    internal
    init<Value>(target: Predicate<Root, Value>)
    {
        self.subpredicate = target.nsPredicate
    }
    
    public
    init(target: any CompoundPredicate)
    {
        self.subpredicate = target.nsPredicate
    }
    
    public
    func evaluate(with object: Root) -> Bool
    {
        let result: Bool = self.nsPredicate.evaluate(with: object)
        
        return result
    }
}

// MARK: - NotPredicate.Subpredicates -

public
extension NotPredicate
{
    fileprivate
    class Subpredicates
    {
        // MARK: - Properties -
        
        fileprivate
        var subpredicates: [NSPredicate] = []
        
        // MARK: - Methods -
        // MARK: Initial Method
        
        fileprivate
        init() { }
        
        fileprivate
        func append(_ predicate: NSPredicate)
        {
            self.subpredicates.append(predicate)
        }
    }
}

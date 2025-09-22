//
//  OrPredicate.swift
//  Predicate
//
//  Created by Darktt on 2025/9/19.
//

import Foundation

public
struct OrPredicate<Root>: CompoundPredicate
{
    // MARK: - Properties -
    
    private
    let subpredicate = Subpredicates()
    
    public
    var nsPredicate: NSPredicate {
        
        NSCompoundPredicate(andPredicateWithSubpredicates: self.subpredicate.subpredicates)
    }
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    internal
    init<Value>(target: Predicate<Root, Value>)
    {
        self.subpredicate.append(target.nsPredicate)
    }
    
    public
    init(target: any CompoundPredicate)
    {
        self.subpredicate.append(target.nsPredicate)
    }
    
    internal
    init<Value, OtherValue>(target: Predicate<Root, Value>, _ other: Predicate<Root, OtherValue>)
    {
        self.subpredicate.subpredicates.append(target.nsPredicate)
        self.subpredicate.subpredicates.append(other.nsPredicate)
    }
    
    internal
    init<Value>(target: Predicate<Root, Value>, _ other: any CompoundPredicate)
    {
        self.subpredicate.subpredicates.append(target.nsPredicate)
        self.subpredicate.subpredicates.append(other.nsPredicate)
    }
    
    public
    init<Value>(target: any CompoundPredicate, _ other: Predicate<Root, Value>)
    {
        self.subpredicate.append(target.nsPredicate)
        self.subpredicate.append(other.nsPredicate)
    }
    
    public
    func and<Value>(_ target: Predicate<Root, Value>) -> AndPredicate<Root>
    {
        let andPredicate = AndPredicate(target: self, target)
        
        return andPredicate
    }
    
    public
    func and(_ target: any CompoundPredicate) -> AndPredicate<Root>
    {
        let andPredicate = AndPredicate<Root>(target: self)
        
        return andPredicate
    }
    
    public
    func or<Value>(_ target: Predicate<Root, Value>) -> OrPredicate<Root>
    {
        self.subpredicate.append(target.nsPredicate)
        
        return self
    }
    
    public
    func or(_ target: any CompoundPredicate) -> OrPredicate<Root>
    {
        self.subpredicate.append(target.nsPredicate)
        
        return self
    }
    
    public
    func not() -> NotPredicate<Root>
    {
        let notPredicate = NotPredicate<Root>(target: self)
        
        return notPredicate
    }
    
    public
    func evaluate(with object: Root) -> Bool
    {
        let result: Bool = self.nsPredicate.evaluate(with: object)
        
        return result
    }
}

// MARK: - OrPredicate.Subpredicates -

public
extension OrPredicate
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

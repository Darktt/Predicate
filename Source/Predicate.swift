//
//  Predicate.swift
//  DTTest
//
//  Created by Eden on 2023/2/23.
//  Copyright © 2023 Darktt. All rights reserved.
//

import Foundation

public
struct Predicate<Root, Value>
{
    // MARK: - Properties -
    
    private
    let actionStack: ActionStack<Root, Value>
    
    internal
    var nsPredicate: NSPredicate {
        
        let (format, arguments) = self.buildPredicateFormat()
        
        return NSPredicate(format: format, argumentArray: arguments)
    }
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public
    static
    func some(_ keyPath: KeyPath<Root, Value>) -> Predicate where Root: Collection
    {
        let predicate = Predicate(some: keyPath)
        
        return predicate
    }
    
    public
    static
    func any(_ keyPath: KeyPath<Root, Value>) -> Predicate where Root: Collection
    {
        let predicate = Predicate(some: keyPath)
        
        return predicate
    }
    
    public
    static
    func all(_ keyPath: KeyPath<Root, Value>) -> Predicate where Root: Collection
    {
        let predicate = Predicate(all: keyPath)
        
        return predicate
    }
    
    public
    static
    func none(_ keyPath: KeyPath<Root, Value>) -> Predicate where Root: Collection
    {
        let predicate = Predicate(none: keyPath)
        
        return predicate
    }
    
    public
    static
    func not(_ keyPath: KeyPath<Root, Value>) -> Predicate
    {
        let predicate = Predicate(not: keyPath)
        
        return predicate
    }
    
    public
    init(_ keyPath: KeyPath<Root, Value>)
    {
        let actionStack = ActionStack(.normal(keyPath))
        
        self.actionStack = actionStack
    }
    
    private
    init(some keyPath: KeyPath<Root, Value>)
    {
        let actionStack = ActionStack(.some(keyPath))
        
        self.actionStack = actionStack
    }
    
    private
    init(all keyPath: KeyPath<Root, Value>)
    {
        let actionStack = ActionStack(.all(keyPath))
        
        self.actionStack = actionStack
    }
    
    private
    init(none keyPath: KeyPath<Root, Value>)
    {
        let actionStack = ActionStack(.none(keyPath))
        
        self.actionStack = actionStack
    }

    private
    init(not keyPath: KeyPath<Root, Value>)
    {
        let actionStack = ActionStack(.not(keyPath))
        
        self.actionStack = actionStack
    }
    
    // MARK: Predicate Operators
    
    public
    func equalTo(_ value: Value) -> Predicate
    {
        self.actionStack.append(.equalTo(value))
        
        return self
    }
    
    public
    func greaterThan(_ value: Value) -> Predicate
    {
        self.actionStack.append(.greaterThan(value))
        
        return self
    }
    
    public
    func greaterThanOrEqualTo(_ value: Value) -> Predicate
    {
        self.actionStack.append(.greaterThanOrEqualTo(value))
        
        return self
    }
    
    public
    func lessThan(_ value: Value) -> Predicate
    {
        self.actionStack.append(.lessThan(value))
        
        return self
    }
    
    public
    func lessThenOrEqualTo(_ value: Value) -> Predicate
    {
        self.actionStack.append(.lessThenOrEqualTo(value))
        
        return self
    }
    
    public
    func notEqualTo(_ value: Value) -> Predicate
    {
        self.actionStack.append(.notEqualTo(value))
        
        return self
    }
    
    public
    func beginWith(_ value: Value, insensitive operators: Set<InsensitivityOperator> = []) -> Predicate
    {
        self.actionStack.append(.beginWith(value, operators: operators))
        
        return self
    }
    
    public
    func `in`(_ values: Array<Value>) -> Predicate
    {
        self.actionStack.append(.in(values))
        
        return self
    }
    
    public
    func and<OtherValue>(_ predicate: Predicate<Root, OtherValue>) -> AndPredicate<Root>
    {
        let andPredicate = AndPredicate(target: self, predicate)
        
        return andPredicate
    }
    
    public
    func and(_ predicate: any CompoundPredicate) -> AndPredicate<Root>
    {
        let andPredicate = AndPredicate(target: self, predicate)
        
        return andPredicate
    }
    
    public
    func or<OtherValue>(_ predicate: Predicate<Root, OtherValue>) -> OrPredicate<Root>
    {
        let orPredicate = OrPredicate(target: self, predicate)
        
        return orPredicate
    }
    
    public
    func or(_ predicate: any CompoundPredicate) -> OrPredicate<Root>
    {
        let orPredicate = OrPredicate(target: self, predicate)
        
        return orPredicate
    }
    
    public
    func not() -> NotPredicate<Root>
    {
        let notPredicate = NotPredicate(target: self)
        
        return notPredicate
    }
    
    public
    func evaluate(with object: Root?) -> Bool
    {
        let predicate: NSPredicate = self.nsPredicate
        let result: Bool = predicate.evaluate(with: object)
        
        return result
    }
}

extension Predicate
{
    fileprivate
    enum Action
    {
        case normal(_ keyPath: KeyPath<Root, Value>)
        
        case not(_ keyPath: KeyPath<Root, Value>)
        
        case some(_ keyPath: KeyPath<Root, Value>)
        
        case all(_ keyPath: KeyPath<Root, Value>)
        
        case none(_ keyPath: KeyPath<Root, Value>)
        
        case equalTo(_ value: Value)
        
        case greaterThan(_ value: Value)
        
        case greaterThanOrEqualTo(_ value: Value)
        
        case lessThan(_ value: Value)
        
        case lessThenOrEqualTo(_ value: Value)
        
        case notEqualTo(_ value: Value)
        
        case beginWith(_ value: Value, operators: Set<InsensitivityOperator>)
        
        case `in`(_ values: Array<Value>)
    }
    
    public
    enum InsensitivityOperator : Character
    {
        case caseInsensitive = "c"
        
        case diacriticInsensitive = "d"
    }
}

// MARK: - Private Methods -

private
extension Predicate
{
    func buildPredicateFormat() -> (format: String, arguments: [Any])
    {
        let actions = self.actionStack.stack
        
        guard let first = actions.first else {
            
            return ("TRUEPREDICATE", [])
        }
        
        // Extract keyPath and potential leading quantifier/not
        let keyPathAndPrefix: (prefix: String, keyPath: String) = {
            
            switch first {
                
                case .normal(let keyPath):
                    return ("", keyPath._keyPathString)
                
                case .not(let keyPath):
                    return ("NOT ", keyPath._keyPathString)
                
                case .some(let keyPath):
                    return ("ANY ", keyPath._keyPathString)
                
                case .all(let keyPath):
                    return ("ALL ", keyPath._keyPathString)
                
                case .none(let keyPath):
                    return ("NONE ", keyPath._keyPathString)
                
                default:
                    // Fallback if first action is unexpectedly an operator
                    return ("", "")
            }
        }()
        
        // Find the first operator action after the keyPath initializer
        let operatorAction: Action? = actions.dropFirst().first(where: { 
            
            action in
            
            switch action {
                
                case .equalTo, .greaterThan, .greaterThanOrEqualTo, .lessThan, .lessThenOrEqualTo, .notEqualTo, .beginWith, .in:
                    return true
                
                default:
                    return false
            }
        })
        
        guard let op = operatorAction, keyPathAndPrefix.keyPath.isEmpty == false else {
            
            return ("TRUEPREDICATE", [])
        }
        
        let key = keyPathAndPrefix.keyPath
        let prefix = keyPathAndPrefix.prefix
        
        switch op {
            
            case .equalTo(let value):
                return ("\(prefix)\(key) == %@", [value as Any])
                
            case .notEqualTo(let value):
                return ("\(prefix)\(key) != %@", [value as Any])
                
            case .greaterThan(let value):
                return ("\(prefix)\(key) > %@", [value as Any])
                
            case .greaterThanOrEqualTo(let value):
                return ("\(prefix)\(key) >= %@", [value as Any])
                
            case .lessThan(let value):
                return ("\(prefix)\(key) < %@", [value as Any])
                
            case .lessThenOrEqualTo(let value):
                return ("\(prefix)\(key) <= %@", [value as Any])
                
            case .in(let values):
                return ("\(prefix)\(key) IN %@", [values as Any])
                
            case .beginWith(let value, let operators):
                let optionString: String = {
                    if operators.isEmpty { return "" }
                    let flags = operators.map { String($0.rawValue) }.sorted().joined()
                    return "[\(flags)]"
                }()
                return ("\(prefix)\(key) BEGINSWITH\(optionString) %@", [value as Any])
                
            default:
                return ("TRUEPREDICATE", [])
        }
    }
}

// MARK: - Private -

fileprivate
class ActionStack<Root, Value>
{
    fileprivate
    typealias Action = Predicate<Root, Value>.Action
    
    fileprivate private(set)
    var stack: Array<Action> = []
    
    fileprivate
    init(_ initAction: Action) {
        
        self.stack.append(initAction)
    }
    
    func append(_ action: Action)
    {
        self.stack.append(action)
    }
}

private
extension KeyPath
{
    /// https://github.com/apple/swift/blob/main/stdlib/public/core/KeyPath.swift#L124
    var _keyPathString: String {
        
        self._kvcKeyPathString ?? ""
    }
}

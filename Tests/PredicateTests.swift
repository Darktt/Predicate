import XCTest
@testable import Predicate

private
class User: NSObject
{
    @objc dynamic
    let name: String
    
    @objc dynamic
    let age: Int
    
    @objc dynamic
    let tags: [String]
    
    init(name: String, age: Int, tags: [String])
    {
        self.name = name
        self.age = age
        self.tags = tags
    }
}

final
class PredicateTests: XCTestCase
{
    func test_equalTo_number()
    {
        let user = User(name: "Eden", age: 18, tags: ["pro", "swift"]) 
        
        let p = Predicate(\User.age).equalTo(18)
        XCTAssertTrue(p.evaluate(with: user))
        
        let p2 = Predicate(\User.age).equalTo(20)
        XCTAssertFalse(p2.evaluate(with: user))
    }
    
    func test_notEqualTo_number()
    {
        let user = User(name: "Eden", age: 30, tags: [])
        
        let p = Predicate(\User.age).notEqualTo(30)
        XCTAssertFalse(p.evaluate(with: user))
        
        let p2 = Predicate(\User.age).notEqualTo(29)
        XCTAssertTrue(p2.evaluate(with: user))
    }
    
    func test_greater_operators()
    {
        let user = User(name: "Alice", age: 40, tags: [])
        
        XCTAssertTrue(Predicate(\User.age).greaterThan(18).evaluate(with: user))
        XCTAssertTrue(Predicate(\User.age).greaterThanOrEqualTo(18).evaluate(with: user))
        XCTAssertTrue(Predicate(\User.age).lessThan(65).evaluate(with: user))
        XCTAssertTrue(Predicate(\User.age).lessThenOrEqualTo(65).evaluate(with: user))
    }
    
    func test_in_operator()
    {
        let user1 = User(name: "Alice", age: 20, tags: [])
        let user2 = User(name: "Carol", age: 22, tags: [])
        
        let p = Predicate(\User.name).in(["Alice", "Bob"]) 
        
        XCTAssertTrue(p.evaluate(with: user1))
        XCTAssertFalse(p.evaluate(with: user2))
    }
    
    func test_like_operator()
    {
        let user = User(name: "Eden", age: 18, tags: [])
        
        let p = Predicate(\User.name).like("Ed*")
        XCTAssertTrue(p.evaluate(with: user))
        
        let p2 = Predicate(\User.name).like("ed*")
        XCTAssertFalse(p2.evaluate(with: user))
    }
    
    func test_beginswith_caseInsensitive()
    {
        let user = User(name: "Eden", age: 18, tags: [])
        
        let p = Predicate(\User.name).beginWith("ed", insensitive: [.caseInsensitive])
        XCTAssertTrue(p.evaluate(with: user))
        
        let p2 = Predicate(\User.name).beginWith("ed", insensitive: [])
        XCTAssertFalse(p2.evaluate(with: user))
        
        let p3 = Predicate(\User.name).beginWith("Ed", insensitive: [])
        XCTAssertTrue(p3.evaluate(with: user))
    }
    
    func test_contains_caseInsensitive()
    {
        let user = User(name: "Eden", age: 18, tags: [])
        
        let p = Predicate(\User.name).contains("de", insensitive: [.caseInsensitive])
        XCTAssertTrue(p.evaluate(with: user))
        
        let p2 = Predicate(\User.name).contains("de", insensitive: [])
        XCTAssertTrue(p2.evaluate(with: user))
        
        let p3 = Predicate(\User.name).contains("De", insensitive: [])
        XCTAssertFalse(p3.evaluate(with: user))
    }
    
    func test_endwith_caseInsensitive()
    {
        let user = User(name: "Eden", age: 18, tags: [])
        
        let p = Predicate(\User.name).endWith("en", insensitive: [.caseInsensitive])
        XCTAssertTrue(p.evaluate(with: user))
        
        let p2 = Predicate(\User.name).endWith("en", insensitive: [])
        XCTAssertTrue(p2.evaluate(with: user))
        
        let p3 = Predicate(\User.name).endWith("En", insensitive: [])
        XCTAssertFalse(p3.evaluate(with: user))
    }
    
    func test_not_prefix()
    {
        let user = User(name: "Eden", age: 10, tags: [])
        
        let p = Predicate.not(\User.age).equalTo(10)
        XCTAssertFalse(p.evaluate(with: user))
        
        let p2 = Predicate.not(\User.age).equalTo(9)
        XCTAssertTrue(p2.evaluate(with: user))
    }
    
    func test_chain_multiple_operators()
    {
        let users = [
            User(name: "Eden", age: 25, tags: ["Swift"]),
            User(name: "Alice", age: 20, tags: ["Kotlin"]),
            User(name: "Bob", age: 30, tags: ["Dart"]),
        ]
        
        let predicate = Predicate(\User.age)
                            .greaterThan(20)
                            .and(
                                Predicate(\User.tags).in([["Swift"], ["Dart"]])
                            )
                            .or(
                                Predicate(\User.name).beginWith("B", insensitive: [.caseInsensitive])
                            )
        
        XCTAssertTrue(users.filter(by: predicate).isEmpty == false)
    }
    
    func test_and_not_and_operator()
    {
        let users = [
            User(name: "Eden", age: 25, tags: ["Swift"]),
            User(name: "Alice", age: 20, tags: ["Kotlin"]),
            User(name: "Bob", age: 30, tags: ["Dart"]),
        ]
        
        let predicate = Predicate(\User.age)
                            .lessThan(28)
                            .and(Predicate(\User.tags).in([["Kotlin"]]).not())
        
        let filtered = users.filter(by: predicate)
        
        XCTAssertTrue(filtered.isEmpty == false)
        
        let user = filtered.first!
        
        XCTAssertEqual(user.name, "Eden")
    }
}

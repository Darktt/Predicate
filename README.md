## Predicate

型別安全的條件組裝器，將 Swift `KeyPath` 與直覺的比對 API 組裝成 `NSPredicate`，可直接用於 Core Data、`NSArray/NSMutableArray` 過濾或 `NSPredicate.evaluate(with:)`。

### 安裝（Swift Package Manager）
- 在 `Package.swift` 的 `dependencies` 或 Xcode 的 Swift Packages 以本專案路徑/URL 加入即可。

### 平台需求
- iOS 13+ / macOS 10.15+ / tvOS 13+ / watchOS 6+

### 快速上手
1) 定義資料模型（KVC 相容）
```swift
final class User: NSObject {
    @objc dynamic let name: String
    @objc dynamic let age: Int
    @objc dynamic let tags: [String]

    init(name: String, age: Int, tags: [String]) {
        self.name = name
        self.age = age
        self.tags = tags
    }
}
```

2) 建立 Predicate 並取得 `NSPredicate`
```swift
// 等於
let p1 = Predicate<User, Int>(\User.age).equalTo(18)
let ns1 = p1.nsPredicate // format: "age == 18"

// 比大小
let p2 = Predicate<User, Int>(\User.age).greaterThanOrEqualTo(21)
let ns2 = p2.nsPredicate // format: "age >= 21"

// IN
let p3 = Predicate<User, String>(\User.name).in(["Alice", "Bob"]) 
let ns3 = p3.nsPredicate // format: "name IN {\"Alice\", \"Bob\"}"

// BEGINSWITH 與大小寫不敏感旗標 [c]
let p4 = Predicate<User, String>(\User.name).beginWith("ed", insensitive: [.caseInsensitive])
let ns4 = p4.nsPredicate // format: "name BEGINSWITH[c] \"ed\""
```

3) 評估資料
```swift
let user = User(name: "Eden", age: 18, tags: ["swift"]) 
let ok = p1.nsPredicate.evaluate(with: user) // true
```

### 集合量詞與否定
- 使用量詞/否定對集合屬性或一般屬性加上前綴：
```swift
// NOT
let notAge10 = Predicate<User, Int>.not(\User.age).equalTo(10)
let nsNot = notAge10.nsPredicate // "NOT age == 10"

// ANY/ALL/NONE（對集合 KeyPath 前綴量詞）
let anyBegins = Predicate<[String], String>.some(\Array<String>.Element).beginWith("pro", insensitive: [.caseInsensitive])
let nsAny = anyBegins.nsPredicate // "ANY SELF BEGINSWITH[c] \"pro\""
```

說明：
- `some` 與 `any` 等價，產生 `ANY` 前綴。
- `all` 產生 `ALL`，`none` 產生 `NONE`，`not` 產生 `NOT`。

### 可用運算子
- 比較：`equalTo(_:)`, `notEqualTo(_:)`, `greaterThan(_:)`, `greaterThanOrEqualTo(_:)`, `lessThan(_:)`, `lessThenOrEqualTo(_:)`
- 字串前綴：`beginWith(_:insensitive:)`
  - 旗標：`InsensitivityOperator.caseInsensitive` → `[c]`，`InsensitivityOperator.diacriticInsensitive` → `[d]`
- 集合：``in(_:)``

### 注意事項
- KVC 鍵路徑：`NSPredicate` 依賴 KVC 字串，請確保模型屬性能被 KVC 解析。最簡單做法是讓模型繼承 `NSObject` 並用 `@objc dynamic` 宣告欲比對的屬性。
- 型別相容性：`Value` 應能被 `NSPredicate` 正確比較（例如：`String`、`NSNumber`/`Int`、`Date`、可比較的自訂型別等）。

### 測試
```bash
swift test
```

測試涵蓋：
- 比較運算（含 evaluate 驗證）
- `IN` 運算
- `BEGINSWITH` 與大小寫不敏感 `[c]`
- `NOT` 前綴

### 待擴充（歡迎 PR）
- `CONTAINS` / `ENDSWITH` / `LIKE` / `MATCHES`
- 多條件串接與 `AND` / `OR` 邏輯
- 更完整的集合量詞示例（`ANY/ALL/NONE` 搭配實際資料結構）



// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Predicate"
    , platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ]
    , products: [
        .library(name: "Predicate", targets: ["Predicate"])
    ]
    , targets: [
        .target(name: "Predicate", path: "Source"),
        .testTarget(name: "PredicateTests", dependencies: ["Predicate"], path: "Tests")
    ]
)

// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCraft",
    products: [
        .library(name: "SwiftCraft", targets: ["SwiftCraft"]),
        .library(name: "SwiftCraftAES", targets: ["SwiftCraftAES"]),
        .library(name: "SwiftCraftReactive", targets: ["SwiftCraftReactive"]),
        .executable(name: "SwiftCraftApp", targets: ["SwiftCraftApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "4.0.4"),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.3.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.1.2")
    ],
    targets: [
        .target(name: "SwiftCraftAES", dependencies: []),
        .target(name: "SwiftCraft", dependencies: ["SwiftCraftAES", "Gzip"]),
        .target(name: "SwiftCraftReactive", dependencies: ["SwiftCraft", "ReactiveSwift"]),
        .target(name: "SwiftCraftApp", dependencies: ["SwiftCraft", "SwiftCraftReactive"]),
        .testTarget(name: "SwiftCraftTests", dependencies: ["SwiftCraft", "Quick", "Nimble"])
    ]
)

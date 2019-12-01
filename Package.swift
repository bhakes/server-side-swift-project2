// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "project2",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
        
        // Fluent SQLite
        .package(url: "https://github.com/vapor/fluent-sqlite.git", .upToNextMinor(from: "3.0.0")),
        
        // Leaf
        .package(url: "https://github.com/vapor/leaf.git", .upToNextMinor(from: "3.0.0")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "FluentSQLite"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)


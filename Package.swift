// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-spreadsheet-gen",
    products: [
        .executable(name: "swift-spreadsheet-gen", targets: ["swift-spreadsheet-gen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "swift-spreadsheet-gen",
            dependencies: ["Commander", "SwiftyJSON"]),
    ]
)

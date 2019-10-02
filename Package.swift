// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-spreadsheet-gen",
    products: [
           .executable(name: "swift-spreadsheet-gen", targets: ["swift-spreadsheet-gen"])
       ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.1"),
    ],
    targets: [
        .target(
            name: "swift-spreadsheet-gen",
            dependencies: []),
        .testTarget(
            name: "swift-spreadsheet-genTests",
            dependencies: ["swift-spreadsheet-gen"]),
    ]
)

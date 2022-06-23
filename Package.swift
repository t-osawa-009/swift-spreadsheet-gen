// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResourceGenerator",
    products: [
        .executable(name: "ResourceGenerator", targets: ["ResourceGenerator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.2"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/swiftcsv/SwiftCSV", from: "0.6.1")
    ],
    targets: [
        .target(
            name: "ResourceGenerator",
        dependencies: ["Commander", "SwiftyJSON", "Files", "Yams", "SwiftCSV"]),
    ]
)

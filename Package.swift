// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIPlus",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftUIPlus",
            targets: ["SwiftUIPlus"]
        ),
    ],
    dependencies: [
         .package(url: "https://github.com/shaps80/SwiftUIBackports", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftUIPlus",
            dependencies: ["SwiftUIBackports"]
        )
    ]
)

// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "FunOptics",
    products: [
        .library(
            name: "FunOptics",
            targets: ["FunOptics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "FunOptics",
            dependencies: ["CasePaths"]),
        .testTarget(
            name: "FunOpticsTests",
            dependencies: ["FunOptics"]),
    ]
)

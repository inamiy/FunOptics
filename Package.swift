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
    ],
    targets: [
        .target(
            name: "FunOptics",
            dependencies: []),
        .testTarget(
            name: "FunOpticsTests",
            dependencies: ["FunOptics"]),
    ]
)

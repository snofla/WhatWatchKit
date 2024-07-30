// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WhatWatchKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WhatWatchKit",
            targets: ["WhatWatchKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WhatWatchKit",
            resources: [
                .copy("Resources/WhatWatchModel.mlmodelc"),
                .copy("Resources/WhetherWatchModel.mlmodelc")
            ]
        ),
        .testTarget(
            name: "WhatWatchKitTests",
            dependencies: [
                "WhatWatchKit",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            resources: [.process("Resources")]
        ),
    ]
)

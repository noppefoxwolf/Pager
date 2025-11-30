// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pager",
    platforms: [.iOS(.v17), .visionOS(.v1)],
    products: [
        .library(
            name: "Pager",
            targets: ["Pager"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/noppefoxwolf/CollectionViewDistributionalLayout", from: "0.0.2")
    ],
    targets: [
        .target(
            name: "Pager",
            dependencies: [
                "CollectionViewDistributionalLayout",
                "LabelContentConfiguration",
            ]
        ),
        .target(
            name: "LabelContentConfiguration"
        ),
        .testTarget(
            name: "PagerTests",
            dependencies: ["Pager"]
        ),
    ]
)

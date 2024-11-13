// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pager",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Pager",
            targets: ["Pager"]
        ),
    ],
    targets: [
        .target(
            name: "Pager",
            dependencies: [
                "ProportionalLayout",
                "LabelContentConfiguration",
            ]
        ),
        .target(
            name: "ProportionalLayout"
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

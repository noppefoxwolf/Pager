// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pager",
    platforms: [.iOS(.v18), .visionOS(.v2)],
    products: [
        .library(
            name: "Pager",
            targets: ["Pager"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/noppefoxwolf/CollectionViewDistributionalLayout",
            from: "0.0.7"
        )
    ],
    targets: [
        .target(
            name: "Pager",
            dependencies: [
                .product(
                    name: "CollectionViewDistributionalLayoutSwiftUI",
                    package: "collectionviewdistributionallayout"
                ),
                "LabelContentConfiguration",
                "ViewControllerContentConfiguration",
            ]
        ),
        .target(
            name: "LabelContentConfiguration"
        ),
        .target(
            name: "ViewControllerContentConfiguration"
        ),
        .testTarget(
            name: "PagerTests",
            dependencies: ["Pager"]
        ),
    ]
)

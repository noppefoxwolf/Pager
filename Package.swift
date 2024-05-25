// swift-tools-version: 5.9
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
            name: "Pager"
        ),
        .testTarget(
            name: "PagerTests",
            dependencies: ["Pager"]
        ),
    ]
)

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ImportObjcForwardDeclarations"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("DeprecateApplicationMain"),
    .enableUpcomingFeature("IsolatedDefaultValues"),
    .enableUpcomingFeature("GlobalConcurrency"),
]

package.targets.forEach { target in
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}


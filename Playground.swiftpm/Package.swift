// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Playground",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "Playground",
            targets: ["AppModule"],
            bundleIdentifier: "0C776FDB-EBFC-4228-BE99-09F9164130D9",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    
    dependencies: [
        .package(path: "../")
    ],
    
    targets: [
        .executableTarget(
            name: "AppModule",
            
            dependencies: [
                .product(
                    name: "Pager",
                    package: "Pager"
                )
            ],
            
            path: "."
        )
    ]
)

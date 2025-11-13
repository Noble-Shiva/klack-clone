// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KlackClone",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "KlackClone",
            targets: ["KlackClone"]
        )
    ],
    targets: [
        .executableTarget(
            name: "KlackClone",
            dependencies: [],
            path: "KlackClone",
            exclude: ["Info.plist", "KlackClone.entitlements"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)

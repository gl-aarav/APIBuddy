// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "APIBuddy",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "APIBuddy", targets: ["APIBuddy"])
    ],
    targets: [
        .executableTarget(
            name: "APIBuddy",
            linkerSettings: [
                .linkedFramework("AppKit")
            ]
        )
    ]
)

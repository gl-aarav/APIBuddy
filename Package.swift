// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "APIVault",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "APIVault", targets: ["APIVault"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "APIVault",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Security")
            ]
        )
    ]
)

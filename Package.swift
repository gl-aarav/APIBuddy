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
    targets: [
        .executableTarget(
            name: "APIVault",
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

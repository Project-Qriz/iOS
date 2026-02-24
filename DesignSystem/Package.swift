// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    dependencies: [
        .package(path: "../QRIZUtils")
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: ["QRIZUtils"],
            resources: [.process("Resources")]
        )
    ]
)


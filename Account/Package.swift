// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Account",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Account", targets: ["Account"]),
    ],
    dependencies: [
        .package(path: "../Auth"),
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils")
    ],
    targets: [
        .target(
            name: "Account",
            dependencies: [
                "Auth",
                "Network",
                "DesignSystem",
                "QRIZUtils"
            ]
        ),
        .testTarget(
            name: "AccountTests",
            dependencies: ["Account"]
        ),
    ]
)

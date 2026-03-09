// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Account",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Account", targets: ["Account"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9")
    ],
    targets: [
        .target(
            name: "Account",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils"
            ]
        ),
        .testTarget(
            name: "AccountTests",
            dependencies: [
                "Account",
                "Network",
                "QRIZUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

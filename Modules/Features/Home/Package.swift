// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Home",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Home", targets: ["Home"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZNetwork"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../Daily"),
        .package(path: "../Exam"),
        .package(path: "../Onboarding"),
        .package(path: "../Conceptbook"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: [
                "QRIZNetwork",
                "DesignSystem",
                "QRIZUtils",
                "Daily",
                "Exam",
                "Onboarding",
                "Conceptbook",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "HomeTests",
            dependencies: [
                "Home",
                "QRIZNetwork",
                "QRIZUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Home",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Home", targets: ["Home"]),
    ],
    dependencies: [
        .package(path: "../../Core/Network"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../Daily"),
        .package(path: "../Exam"),
        .package(path: "../Onboarding"),
        .package(path: "../Conceptbook"),
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: [
                "Network",
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
            dependencies: ["Home"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

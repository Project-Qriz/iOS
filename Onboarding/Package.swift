// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Onboarding", targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(path: "../ExamKit"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

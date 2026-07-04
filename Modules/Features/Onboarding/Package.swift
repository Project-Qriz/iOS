// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Onboarding", targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZNetwork"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../ExamKit"),
        .package(path: "../OnboardingInterface"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                "QRIZNetwork",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
                "OnboardingInterface",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: [
                "Onboarding",
                "QRIZNetwork",
                "QRIZUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

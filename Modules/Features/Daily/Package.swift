// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Daily",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Daily", targets: ["Daily"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZNetwork"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../ExamKit"),
        .package(path: "../Conceptbook"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "Daily",
            dependencies: [
                "QRIZNetwork",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
                "Conceptbook",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "DailyTests",
            dependencies: [
                "Daily",
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

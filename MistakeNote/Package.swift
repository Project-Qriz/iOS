// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MistakeNote",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MistakeNote", targets: ["MistakeNote"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(path: "../Conceptbook"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "MistakeNote",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "Conceptbook",
            ]
        ),
        .testTarget(
            name: "MistakeNoteTests",
            dependencies: [
                "MistakeNote",
                "Network",
                "QRIZUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

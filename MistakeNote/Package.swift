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
    ]
)

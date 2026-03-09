// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Conceptbook",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Conceptbook", targets: ["Conceptbook"]),
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9")
    ],
    targets: [
        .target(
            name: "Conceptbook",
            dependencies: ["DesignSystem", "QRIZUtils"]
        ),
        .testTarget(
            name: "ConceptbookTests",
            dependencies: [
                "Conceptbook",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            resources: [.process("Resources")]
        ),
    ]
)

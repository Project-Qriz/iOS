// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Conceptbook",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Conceptbook", targets: ["Conceptbook"]),
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../ConceptbookInterface"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9")
    ],
    targets: [
        .target(
            name: "Conceptbook",
            dependencies: ["DesignSystem", "QRIZUtils", "ConceptbookInterface"]
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

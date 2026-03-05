// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Conceptbook",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Conceptbook", targets: ["Conceptbook"]),
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils")
    ],
    targets: [
        .target(
            name: "Conceptbook",
            dependencies: ["DesignSystem", "QRIZUtils"]
        ),
        .testTarget(
            name: "ConceptbookTests",
            dependencies: ["Conceptbook"],
            resources: [.process("Resources")]
        ),
    ]
)

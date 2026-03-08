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
        .package(url: "https://github.com/uber/ios-snapshot-test-case", from: "8.0.0")
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
                .product(name: "iOSSnapshotTestCase", package: "ios-snapshot-test-case")
            ],
            resources: [.process("Resources")]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Daily",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Daily", targets: ["Daily"]),
    ],
    dependencies: [
        .package(path: "../../Core/Network"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../ExamKit"),
        .package(path: "../Conceptbook"),
        .package(path: "../MistakeNote"),
    ],
    targets: [
        .target(
            name: "Daily",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
                "Conceptbook",
                "MistakeNote",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

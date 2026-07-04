// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Exam",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Exam", targets: ["Exam"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZNetwork"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../ExamKit"),
        .package(path: "../ExamInterface"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "Exam",
            dependencies: [
                "QRIZNetwork",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
                "ExamInterface",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "ExamTests",
            dependencies: [
                "Exam",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

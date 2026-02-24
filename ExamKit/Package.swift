// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ExamKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "ExamKit", targets: ["ExamKit"])
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils")
    ],
    targets: [
        .target(
            name: "ExamKit",
            dependencies: ["DesignSystem", "QRIZUtils"]
        )
    ]
)

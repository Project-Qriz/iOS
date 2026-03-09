// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ExamKit",
    platforms: [.iOS(.v17)],
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
        ),
        .testTarget(
            name: "ExamKitTests",
            dependencies: [
                "ExamKit",
                .product(name: "QRIZUtils", package: "QRIZUtils")
            ]
        )
    ]
)

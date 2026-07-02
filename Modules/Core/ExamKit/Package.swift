// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ExamKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ExamKit", targets: ["ExamKit"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../../Core/QRIZNetwork")
    ],
    targets: [
        .target(
            name: "ExamKit",
            dependencies: ["DesignSystem", "QRIZUtils", "QRIZNetwork"]
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

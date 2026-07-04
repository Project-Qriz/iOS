// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ExamInterface",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ExamInterface", targets: ["ExamInterface"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../../Core/QRIZNetwork"),
    ],
    targets: [
        .target(
            name: "ExamInterface",
            dependencies: ["QRIZUtils", "QRIZNetwork"]
        ),
    ]
)

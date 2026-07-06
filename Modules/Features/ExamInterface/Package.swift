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
    ],
    targets: [
        .target(
            name: "ExamInterface",
            dependencies: ["QRIZUtils"]
        ),
    ]
)

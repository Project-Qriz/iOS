// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DailyInterface",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DailyInterface", targets: ["DailyInterface"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZUtils"),
    ],
    targets: [
        .target(
            name: "DailyInterface",
            dependencies: ["QRIZUtils"]
        ),
    ]
)

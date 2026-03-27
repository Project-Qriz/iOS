// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "QRIZUtils",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "QRIZUtils",
            targets: ["QRIZUtils"]
        ),
    ],
    targets: [
        .target(
            name: "QRIZUtils"
        ),
    ]
)

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "QRIZUtils",
    platforms: [.iOS(.v15)],
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

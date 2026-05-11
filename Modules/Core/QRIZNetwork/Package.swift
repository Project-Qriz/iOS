// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRIZNetwork",
    platforms: [.iOS(.v17)],
    products: [.library(name: "QRIZNetwork", targets: ["QRIZNetwork"]),],
    dependencies: [.package(path: "../QRIZUtils")],
    targets: [
        .target(name: "QRIZNetwork", dependencies: ["QRIZUtils"], path: "Sources/Network"),
        .testTarget(name: "QRIZNetworkTests", dependencies: ["QRIZNetwork"], path: "Tests/NetworkTests")
    ]

)

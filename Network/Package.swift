// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v15)],
    products: [.library(name: "Network", targets: ["Network"]),],
    dependencies: [.package(path: "../QRIZUtils")],
    targets: [
        .target(name: "Network", dependencies: ["QRIZUtils"]),
        .testTarget(name: "NetworkTests", dependencies: ["Network"])
    ]
    
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OnboardingInterface",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "OnboardingInterface", targets: ["OnboardingInterface"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZUtils"),
    ],
    targets: [
        .target(
            name: "OnboardingInterface",
            dependencies: ["QRIZUtils"]
        ),
    ]
)

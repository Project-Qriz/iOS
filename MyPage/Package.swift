// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MyPage",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MyPage", targets: ["MyPage"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(path: "../Auth"),
        .package(path: "../Account"),
    ],
    targets: [
        .target(
            name: "MyPage",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "Auth",
                "Account",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

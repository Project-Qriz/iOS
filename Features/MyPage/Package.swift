// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MyPage",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MyPage", targets: ["MyPage"]),
    ],
    dependencies: [
        .package(path: "../../Core/Network"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../Auth"),
        .package(path: "../Account"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
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
        .testTarget(
            name: "MyPageTests",
            dependencies: [
                "MyPage",
                "Network",
                "Account",
                "QRIZUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

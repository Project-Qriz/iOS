// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MyPage",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MyPage", targets: ["MyPage"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZNetwork"),
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
                "QRIZNetwork",
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
                "QRIZNetwork",
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

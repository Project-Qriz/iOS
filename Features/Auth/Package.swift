// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Auth", targets: ["Auth"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kakao/kakao-ios-sdk", branch: "master"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.0.0"),
        .package(path: "../../Core/Network"),
        .package(path: "../../Core/QRIZUtils")
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "KakaoSDKCommon", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKAuth", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKUser", package: "kakao-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "Network",
                "QRIZUtils"
            ]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ConceptbookInterface",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ConceptbookInterface", targets: ["ConceptbookInterface"]),
    ],
    dependencies: [
        .package(path: "../../Core/QRIZUtils"),
    ],
    targets: [
        .target(
            name: "ConceptbookInterface",
            dependencies: ["QRIZUtils"]
        ),
    ]
)

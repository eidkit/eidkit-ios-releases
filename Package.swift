// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EidKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "EidKit", targets: ["EidKit"]),
        .library(name: "EidKitOtlp", targets: ["EidKitOtlp"])
    ],
    dependencies: [
        .package(url: "https://github.com/open-telemetry/opentelemetry-swift-core.git", from: "2.3.0"),
    ],
    targets: [
        .binaryTarget(
            name: "EidKit",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKit-0.1.3.xcframework.zip",
            checksum: "edaf78c2a0a861034d6068f7d4262f7a7054eb1c650b4d8cc7d2785f75827013"
        ),
        .binaryTarget(
            name: "EidKitOtlp",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKitOtlp-0.1.3.xcframework.zip",
            checksum: "f29b90899e2ae335a6b2f4836ef9d48ec910bbaa3816a37f3af06eeab774e71d"
        )
    ]
)

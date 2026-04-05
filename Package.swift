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
            checksum: "a6ccc20d44cc0d03b8cf83d840a44858f078a957bb71d57fae0fba06778830d8"
        ),
        .binaryTarget(
            name: "EidKitOtlp",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKitOtlp-0.1.3.xcframework.zip",
            checksum: "8ce694ac42c4373711ea7fd3875495d3c2a0c28ac41b75c44e2332de1c26e900"
        )
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EidKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "EidKit", targets: ["EidKit", "EidKitRuntime"]),
        .library(name: "EidKitOtlp", targets: ["EidKitOtlp"])
    ],
    dependencies: [
        .package(url: "https://github.com/open-telemetry/opentelemetry-swift-core.git", from: "2.3.0"),
        .package(url: "https://github.com/krzyzanowskim/OpenSSL", from: "3.6.0000"),
    ],
    targets: [
        .binaryTarget(
            name: "EidKit",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.11/EidKit-0.1.11.xcframework.zip",
            checksum: "e8fccc833b5087b85da7461c184bbba78be4939508ed4a84e5861599f0a6214c"
        ),
        .target(
            name: "EidKitRuntime",
            dependencies: [
                .product(name: "OpenSSL", package: "OpenSSL"),
            ],
            path: "Sources/EidKitRuntime"
        ),
        .target(
            name: "EidKitOtlp",
            dependencies: [
                "EidKit",
                .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift-core"),
            ],
            path: "Sources/EidKitOtlp"
        )
    ]
)

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
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKit-0.1.3.xcframework.zip",
            checksum: "5767230daebfb7e2b04f4b0d10d5c6b9380e679eb1dfab2322ca61b720565d58"
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
                .product(name: "OpenTelemetryApi", package: "opentelemetry-swift-core"),
                .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift-core"),
            ],
            path: "Sources/EidKitOtlp"
        )
    ]
)

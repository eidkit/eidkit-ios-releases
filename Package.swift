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
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.4/EidKit-0.1.4.xcframework.zip",
            checksum: "4a299634862a110ba37d8a16a7733ff44df4414245ff1fd1d266662836a8861b"
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

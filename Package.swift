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
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.8/EidKit-0.1.8.xcframework.zip",
            checksum: "c4cc1b72c03eaf02a840c452d0433a72dac9f3b45787c43660e8b01dedb2682a"
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

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
            checksum: "4c653b5e07d9d83b032c597a04c12ff1a9729a38c91f1eeaca9198054606d553"
        ),
        .binaryTarget(
            name: "EidKitOtlp",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKitOtlp-0.1.3.xcframework.zip",
            checksum: "b806f42af8cc480a311e81ea81cbd272c0a83188193cc663b46273d155a9b64a"
        )
    ]
)

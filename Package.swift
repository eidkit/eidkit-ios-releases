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
            checksum: "469c5691fb00c281b0ace5eb567bfdcc19676d05ec6341629597c90186c34daa"
        ),
        .binaryTarget(
            name: "EidKitOtlp",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKitOtlp-0.1.3.xcframework.zip",
            checksum: "42c220f80fa11ac568816dafa5497aa5b63da0cebb31065a72a18cd0b4397340"
        )
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EidKit",
    platforms: [.iOS(.v15)],
    products: [.library(name: "EidKit", targets: ["EidKit"])],
    targets: [
        .binaryTarget(
            name: "EidKit",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.0/EidKit-0.1.0.xcframework.zip",
            checksum: "828d63d1c61003bc16d3c3152cf514fca2c235d37b3d2978a82184ef9237e7c8"
        )
    ]
)

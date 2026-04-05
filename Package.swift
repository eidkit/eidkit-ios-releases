// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EidKit",
    platforms: [.iOS(.v15)],
    products: [.library(name: "EidKit", targets: ["EidKit"])],
    targets: [
        .binaryTarget(
            name: "EidKit",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.2/EidKit-0.1.2.xcframework.zip",
            checksum: "6e1f9fc19517417491ea8f8e676f43999a2567963e385b2a7e9fe31d10c25bbe"
        )
    ]
)

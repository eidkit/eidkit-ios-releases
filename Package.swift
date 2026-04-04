// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EidKit",
    platforms: [.iOS(.v15)],
    products: [.library(name: "EidKit", targets: ["EidKit"])],
    targets: [
        .binaryTarget(
            name: "EidKit",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.1/EidKit-0.1.1.xcframework.zip",
            checksum: "ac8b4239cb08ba841ad557c2eaf2597108f1c3f9c130bca8edbdc8c95b2b5aa4"
        )
    ]
)

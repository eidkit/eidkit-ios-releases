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
            checksum: "d341d51f85d536469dae4a56077b815c5c8cdbda586c5d3796076eb3412c3362"
        )
    ]
)

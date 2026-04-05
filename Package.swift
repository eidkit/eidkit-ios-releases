// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EidKit",
    platforms: [.iOS(.v15)],
    products: [.library(name: "EidKit", targets: ["EidKit"])],
    targets: [
        .binaryTarget(
            name: "EidKit",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKit-0.1.3.xcframework.zip",
            checksum: "0b3aeebd8ae72fc4282fec27e1b884b73f9ca95d71d6b8a752b9dd40821234f0"
        )
    ]
)

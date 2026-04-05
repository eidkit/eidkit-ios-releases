// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EidKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "EidKit", targets: ["EidKit"]),
        .library(name: "EidKitOtlp", targets: ["EidKitOtlp"])
    ],
    targets: [
        .binaryTarget(
            name: "EidKit",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKit-0.1.3.xcframework.zip",
            checksum: "8ec18c08ddcc1d69b4ddfbe8202d68a6c4410ceec333e567e3961ab6a023180a"
        ),
        .binaryTarget(
            name: "EidKitOtlp",
            url: "https://github.com/eidkit/eidkit-ios-releases/releases/download/v0.1.3/EidKitOtlp-0.1.3.xcframework.zip",
            checksum: "303f4678836315cf1d8f5d8f36e0c1dc3e74a30479c8a2660c0cdf35c0a9be1a"
        )
    ]
)

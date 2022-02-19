// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SkyRamp",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "SkyRamp",
            targets: ["SkyRamp"]),
        .library(
            name: "SkyRampMocks",
            targets: ["SkyRampMocks"])
    ],
    targets: [
        .target(
            name: "SkyRamp",
            dependencies: [],
            path: "Sources"),
        .target(
            name: "SkyRampMocks",
            dependencies: ["SkyRamp"],
            path: "Tests/Mocks"),
        .testTarget(
            name: "SkyRampTests",
            dependencies: ["SkyRamp", "SkyRampMocks"],
            path: "Tests/SkyRampTests")
    ],
    swiftLanguageVersions: [.v5]
)

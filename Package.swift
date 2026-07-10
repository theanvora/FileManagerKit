// swift-tools-version: 6.2
import PackageDescription

let concurrencyBaseline: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(nil),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "FileManagerKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "AnvyxFileKit", targets: ["AnvyxFileKit"]),
    ],
    targets: [
        .target(name: "AnvyxFileKit", swiftSettings: concurrencyBaseline),
        .testTarget(name: "AnvyxFileKitTests", dependencies: ["AnvyxFileKit"], swiftSettings: concurrencyBaseline),
    ]
)

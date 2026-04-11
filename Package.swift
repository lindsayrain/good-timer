// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GoodTimer",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "GoodTimer",
            path: "Sources/GoodTimer",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "GoodTimerTests",
            dependencies: ["GoodTimer"],
            path: "Tests/GoodTimerTests"
        )
    ]
)

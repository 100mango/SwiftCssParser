// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftCssParser",
    platforms: [.iOS("9.0")],
    products: [
        .library(name: "SwiftCssParser", targets: ["SwiftCssParser"])
    ],
    targets: [
        .target(
            name: "SwiftCssParser",
            path: "SwiftCssParser",
            exclude: [
                "AppDelegate.swift",
                "ViewController.swift",
                "Assets.xcassets",
                "Base.lproj",
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "SwiftCssParserTests",
            dependencies: ["SwiftCssParser"],
            path: "SwiftCssParserTests",
            exclude: ["Info.plist"],
            resources: [.copy("test.css")]
        )
    ],
    swiftLanguageVersions: [.v5]
)

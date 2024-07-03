// swift-tools-version: 5.10

/* Native */
import PackageDescription

// MARK: - Package

let package = Package(
    name: "AlertKit",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "AlertKit",
            targets: ["AlertKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/grantbrooksgoodman/translator", branch: "main"),
//        .package(url: "https://github.com/nicklockwood/SwiftFormat", branch: "main"),
//        .package(url: "https://github.com/realm/SwiftLint", branch: "main"),
    ],
    targets: [
        .target(
            name: "AlertKit",
            dependencies: [.product(name: "Translator", package: "translator", moduleAliases: nil)],
            path: "Sources",
            plugins: [ /* .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint") */ ]
        ),
    ]
)

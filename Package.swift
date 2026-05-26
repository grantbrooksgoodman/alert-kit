// swift-tools-version: 6.0

/* Native */
import PackageDescription

// MARK: - Package

let package = Package(
    name: "AlertKit",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "AlertKit",
            targets: ["AlertKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/grantbrooksgoodman/translator",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "AlertKit",
            dependencies: [
                .product(
                    name: "Translator",
                    package: "translator",
                    moduleAliases: nil
                ),
            ],
            path: "Sources",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)

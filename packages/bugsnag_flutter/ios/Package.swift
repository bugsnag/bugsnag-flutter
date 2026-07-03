// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "bugsnag_flutter",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "bugsnag_flutter",
            targets: ["bugsnag_flutter"]
        )
    ],
    dependencies: [
        // Keep Bugsnag pinned to the same version as the current podspec during migration.
        .package(url: "https://github.com/bugsnag/bugsnag-cocoa.git", exact: "6.33.1")
    ],
    targets: [
        .target(
            name: "bugsnag_flutter",
            dependencies: [
                .product(name: "Bugsnag", package: "bugsnag-cocoa")
            ],
            path: ".",
            sources: ["Classes"],
            resources: [
                .process("Resources/PrivacyInfo.xcprivacy")
            ],
            publicHeadersPath: "Classes"
        )
    ]
)










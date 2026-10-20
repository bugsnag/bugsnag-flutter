// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let bugsnagCocoaVersion: Version = "6.38.0"

let package = Package(
    name: "bugsnag_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "bugsnag-flutter", targets: ["bugsnag_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/bugsnag/bugsnag-cocoa", exact: bugsnagCocoaVersion),
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "bugsnag_flutter",
            dependencies: [
                .product(name: "Bugsnag", package: "bugsnag-cocoa"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/bugsnag_flutter")
            ]
        )
    ]
)

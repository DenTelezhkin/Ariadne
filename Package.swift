// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Ariadne",
    products: [
        .library(name: "Ariadne", targets: ["Ariadne"])
    ],
    targets: [
         .target(name: "Ariadne"),
         .testTarget(name: "Tests", dependencies: ["Ariadne"])
    ],
    swiftLanguageVersions: [.v5, .v4_2]
)

// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Languages",
    platforms: [ .iOS(.v10), .tvOS(.v9), .watchOS(.v2), .macOS(.v10_10) ],
    products: [.library(name: "Languages", targets: ["Languages"]), ],
    dependencies: [],
    targets: [.target(name: "Languages", dependencies: []), ]
)

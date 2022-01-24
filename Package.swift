// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ManagedObjectObserver",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "ManagedObjectObserver", targets: ["ManagedObjectObserver"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ManagedObjectObserver", dependencies: []),
    ]
)

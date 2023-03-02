// swift-tools-version:5.5

import PackageDescription

/// Rename this name + Root Folder + Target Folder inside Source
let name: String = "everspace-center"

let packageDependencies: [Package.Dependency] = [
    .package(name: "vapor", url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.45.0")),
    .package(name: "PostgresBridge", url: "https://github.com/SwifQL/PostgresBridge.git", .upToNextMajor(from:"1.0.0-rc")),
    .package(name: "VaporBridges", url: "https://github.com/SwifQL/VaporBridges.git", .upToNextMajor(from: "1.0.0-rc")),
    .package(name: "Bridges", url: "https://github.com/SwifQL/Bridges.git", .upToNextMajor(from: "1.0.0-rc.4.13.1")),
    .package(name: "SwiftRegularExpression", url: "https://github.com/nerzh/swift-regular-expression.git", .upToNextMajor(from: "0.2.3")),
    .package(name: "EverscaleClientSwift", url: "https://github.com/nerzh/everscale-client-swift", .upToNextMajor(from: "1.4.1")),
    .package(name: "FCM", url: "https://github.com/MihaelIsaev/FCM", .upToNextMajor(from: "2.8.0")),
    .package(name: "FileUtils", url: "https://github.com/nerzh/SwiftFileUtils", .upToNextMinor(from: "1.3.0")),
    .package(name: "SwiftExtensionsPack", url: "https://github.com/nerzh/swift-extensions-pack", .upToNextMajor(from: "0.4.7")),
]

let mainTarget: [Target.Dependency] = [
    .product(name: "Vapor", package: "vapor"),
    .product(name: "PostgresBridge", package: "PostgresBridge"),
    .product(name: "VaporBridges", package: "VaporBridges"),
    .product(name: "Bridges", package: "Bridges"),
    .product(name: "SwiftRegularExpression", package: "SwiftRegularExpression"),
    .product(name: "EverscaleClientSwift", package: "EverscaleClientSwift"),
    .product(name: "FCM", package: "FCM"),
    .product(name: "FileUtils", package: "FileUtils"),
    .product(name: "SwiftExtensionsPack", package: "SwiftExtensionsPack"),
]

let package = Package(
    name: name,
    platforms: [
        .macOS(.v12)
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: name,
            dependencies: mainTarget
        )
    ]
)



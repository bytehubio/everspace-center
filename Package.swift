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
    .package(name: "FileUtils", url: "https://github.com/nerzh/SwiftFileUtils", .upToNextMinor(from: "1.3.0")),
    .package(name: "SwiftExtensionsPack", url: "https://github.com/nerzh/swift-extensions-pack", .upToNextMajor(from: "1.2.0")),
    .package(name: "IkigaJSON", url: "https://github.com/orlandos-nl/IkigaJSON.git", from: "2.0.0"),
    .package(name: "BigInt", url: "https://github.com/bytehubio/BigInt.git", .exact("5.3.0")),
//    .package(path: "/Users/nerzh/mydata/swift_projects/Swiftgger"),
    .package(url: "https://github.com/nerzh/Swiftgger", .upToNextMajor(from: "2.0.2")),
//    .package(url: "https://github.com/tonkeeper/ton-swift", .branch("main")),
//    .package(path: "/Users/nerzh/mydata/swift_projects/ton-swift")
]

let mainTarget: [Target.Dependency] = [
    .product(name: "Vapor", package: "vapor"),
    .product(name: "PostgresBridge", package: "PostgresBridge"),
    .product(name: "VaporBridges", package: "VaporBridges"),
    .product(name: "Bridges", package: "Bridges"),
    .product(name: "SwiftRegularExpression", package: "SwiftRegularExpression"),
    .product(name: "EverscaleClientSwift", package: "EverscaleClientSwift"),
    .product(name: "FileUtils", package: "FileUtils"),
    .product(name: "SwiftExtensionsPack", package: "SwiftExtensionsPack"),
    .product(name: "IkigaJSON", package: "IkigaJSON"),
    .product(name: "BigInt", package: "BigInt"),
    .product(name: "Swiftgger", package: "Swiftgger"),
//    .product(name: "TonSwift", package: "ton-swift"),
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



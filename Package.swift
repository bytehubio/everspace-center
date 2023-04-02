// swift-tools-version:5.8

import PackageDescription

/// Rename this name + Root Folder + Target Folder inside Source
let name: String = "everspace-center"

let packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.45.0")),
    .package(url: "https://github.com/SwifQL/PostgresBridge.git", .upToNextMajor(from:"1.0.0-rc")),
    .package(url: "https://github.com/SwifQL/VaporBridges.git", .upToNextMajor(from: "1.0.0-rc")),
    .package(url: "https://github.com/SwifQL/Bridges.git", .upToNextMajor(from: "1.0.0-rc.4.13.1")),
    .package(url: "https://github.com/nerzh/swift-regular-expression.git", .upToNextMajor(from: "0.2.3")),
    .package(url: "https://github.com/nerzh/everscale-client-swift", .upToNextMajor(from: "1.4.1")),
    .package(url: "https://github.com/nerzh/SwiftFileUtils", .upToNextMinor(from: "1.3.0")),
    .package(url: "https://github.com/nerzh/swift-extensions-pack", .upToNextMajor(from: "1.2.0")),
    .package(url: "https://github.com/orlandos-nl/IkigaJSON.git", from: "2.0.0"),
    .package(url: "https://github.com/bytehubio/BigInt.git", exact: "5.3.0"),
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
    .product(name: "SwiftRegularExpression", package: "swift-regular-expression"),
    .product(name: "EverscaleClientSwift", package: "everscale-client-swift"),
    .product(name: "FileUtils", package: "SwiftFileUtils"),
    .product(name: "SwiftExtensionsPack", package: "swift-extensions-pack"),
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
    products: [
        .executable(name: name, targets: [name])
    ],
    dependencies: packageDependencies,
    targets: [
        .executableTarget(name: name, dependencies: mainTarget),
    ]
)



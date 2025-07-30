// swift-tools-version:5.9

import PackageDescription

/// Rename this name + Root Folder + Target Folder inside Source
let name: String = "tvm-center"

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.45.0")),
    .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver", .upToNextMajor(from: "2.9.2")),
    .package(url: "https://github.com/nerzh/swift-regular-expression.git", .upToNextMajor(from: "0.2.3")),
    .package(url: "https://github.com/nerzh/SwiftFileUtils", .upToNextMinor(from: "1.3.0")),
    .package(url: "https://github.com/orlandos-nl/IkigaJSON.git", from: "2.0.0"),
    .package(url: "https://github.com/bytehubio/BigInt.git", exact: "5.3.0"),
    .package(url: "https://github.com/vapor/postgres-nio", exact: "1.25.0"),
]

var mainTarget: [Target.Dependency] = [
    .product(name: "Vapor", package: "vapor"),
    .product(name: "Fluent", package: "fluent"),
    .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
    .product(name: "SwiftRegularExpression", package: "swift-regular-expression"),
    .product(name: "FileUtils", package: "SwiftFileUtils"),
    .product(name: "IkigaJSON", package: "IkigaJSON"),
    .product(name: "BigInt", package: "BigInt"),
    
    .product(name: "EverscaleClientSwift", package: "everscale-client-swift"),
    .product(name: "SwiftExtensionsPack", package: "swift-extensions-pack"),
    .product(name: "Swiftgger", package: "Swiftgger"),
    .product(name: "PostgresNIO", package: "postgres-nio"),
]

#if os(Linux)
packageDependencies.append(.package(url: "https://github.com/nerzh/Swiftgger", branch: "master"))
packageDependencies.append(.package(url: "https://github.com/nerzh/swift-extensions-pack", exact: "1.26.0"))
packageDependencies.append(.package(url: "https://github.com/nerzh/everscale-client-swift", .upToNextMajor(from: "1.12.0")))
#else
packageDependencies.append(.package(path: "/Users/nerzh/Documents/mydata/code/swift_projects/test/Swiftgger"))
//packageDependencies.append(.package(path: "/Users/nerzh/Documents/mydata/code/swift_projects/swift-extensions-pack"))
packageDependencies.append(.package(url: "https://github.com/nerzh/swift-extensions-pack", exact: "1.26.0"))
packageDependencies.append(.package(path: "/Users/nerzh/Documents/mydata/code/swift_projects/everscale-client-swift"))
#endif

let package = Package(
    name: name,
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: name, targets: [name])
    ],
    dependencies: packageDependencies,
    targets: [
        .executableTarget(
            name: name,
            dependencies: mainTarget
        ),
    ]
)



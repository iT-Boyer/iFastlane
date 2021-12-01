// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Runner",
    products: [
        .executable(name: "Runner", targets: ["Runner"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//    	.package(name: "Fastlane", url: "https://github.com/fastlane/fastlane", from: "2.179.0"),
        .package(name: "Fastlane", path: "/Users/boyer/hsg/fastlane"),
        .package(name: "Regex", path: "/Users/boyer/hsg/Regex"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/pvieito/PythonKit.git",  .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.11.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        .executableTarget(
            name: "Runner",
            dependencies: ["Fastlane",
                           "Regex",
                           "SwiftyJSON",
                           "PythonKit",
                           "XcodeProj",
                           .product(name: "ArgumentParser", package: "swift-argument-parser")
                          ],
            path: "swift",
            exclude: ["iTBoyer/APP/iBlink/gym.plist","iTBoyer/APP/SupervisionSel/gym.plist"],
            sources:["."]
	)
    ]
)

// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Runner",
    platforms: [
      .macOS(.v11), .iOS(.v9), .tvOS(.v9)
    ],
    products: [
        .executable(name: "Runner", targets: ["Runner"]),
        .library(name: "CmdLib", targets: ["CmdLib"])
    ],
    dependencies: [
        .package(name: "Fastlane", path: "/Users/boyer/hsg/fastlane"),
        .package(name: "Regex", url: "https://github.com/sharplet/Regex",.upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/pvieito/PythonKit.git",  .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.11.1")),
        //quick行为测试
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/it-boyer/Nimble.git",.branch("main"))
        //Cannot find 'XCTFail' in scope
//        .package(name: "Nimble", path: "/Users/boyer/hsg/Nimble")
    ],
    targets: [
        .executableTarget(name: "Runner",
                          dependencies: ["CmdLib",
                                         "Fastlane",
                                         "Regex",
                                         "SwiftyJSON",
                                         "PythonKit",
                                         "XcodeProj",
                                         .product(name: "ArgumentParser", package: "swift-argument-parser")
                                        ],
                          path: "swift",
                          exclude: ["iTBoyer/APP/iBlink/gym.plist","iTBoyer/APP/SupervisionSel/gym.plist"],
                          sources:["."]
                         ),
        .target(
            name: "CmdLib",
            dependencies: ["Fastlane",
                           "Regex",
                           "SwiftyJSON",
                           "PythonKit",
                           "XcodeProj",
                           .product(name: "ArgumentParser", package: "swift-argument-parser")
                          ],
            path: "CmdLib",
            exclude: [],
            sources:["."]
        ),
        .testTarget(
            name: "CmdLibTests",
            dependencies: ["CmdLib","Quick","Nimble"])
    ],
    swiftLanguageVersions: [.v5]
)

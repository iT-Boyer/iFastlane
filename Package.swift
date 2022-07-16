// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var thirdLibs:[Target.Dependency] = ["Regex",
                                     "GRDB",
                                     "Shout",
                                     "SwiftShell",
                                     "SwiftyJSON",
                                     "PythonKit",
                                     "XcodeProj",
                                     "GithubAPI",
                                     "Alamofire",
                                     "XMLCoder",
                                     "SwiftSoup",
                                     "AlfredSwift",
                                     // "CoreXLSX",
                                     .product(name: "CSV", package: "CSV.swift"),
                                     .product(name: "ArgumentParser", package: "swift-argument-parser")
                                    ]

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
        .package(name: "Alamofire", path: "/Users/boyer/hsg/Alamofire"),
        .package(name: "Regex", url: "https://github.com/sharplet/Regex",.upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/pvieito/PythonKit.git",  .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.11.1")),
        //quick行为测试
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git",.branch("main")),
        .package(url: "https://github.com/serhii-londar/GithubAPI.git",.branch("master")),
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift.git", from: "5.17.0"),
        //ssh框架
        .package(name: "Shout", url: "https://github.com/jakeheis/Shout", from: "0.5.5"),
        .package(name: "CSV.swift", url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.4.3")),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.13.1"),
        //解析html
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.4.3"),
        .package(url: "https://github.com/iT-Boyer/AlfredSwift.git", .branch("main")),
        .package(url: "https://github.com/kareman/SwiftShell", .upToNextMajor(from: "5.1.0")),
        // CoreXLSX 依赖XMLCoder
        // .package(url: "https://github.com/CoreOffice/CoreXLSX.git", .upToNextMinor(from: "0.14.1")),
        //swift版本plantuml
//        .package(name: "SwiftPlantUML", url: "https://github.com/MarcoEidinger/SwiftPlantUML.git", .upToNextMajor(from: "0.5.0"))
        //Cannot find 'XCTFail' in scope
//        .package(name: "Nimble", path: "/Users/boyer/hsg/Nimble")
    ],
    targets: [
        .executableTarget(name: "Runner",
                          dependencies: thirdLibs + ["Fastlane", "CmdLib"],
                          path: "swift",
                          exclude: ["APP/iBlink/gym.plist",
                                    "APP/SupervisionSel/gym.plist",
                                    "Alfred/README.md"],
                          sources:["."]
                         ),
        .target(
            name: "CmdLib",
            dependencies: thirdLibs,
            path: "CmdLib",
            exclude: ["jazzy.yaml"],
            sources:["."]
        ),
        .testTarget(
            name: "CmdLibTests",
            dependencies: ["CmdLib", "Quick", "Nimble"])
    ],
    swiftLanguageVersions: [.v5]
)

addRunLib(name: "Alfred")


func addRunLib(name:String) {
    let target = Target.executableTarget(name: name,
                                         dependencies: thirdLibs + ["CmdLib"],
                                                 path: name,
                                                 exclude: [],
                                                 sources:["."])
    
    let library = Product.executable(name: name, targets: [name]) //type: .static,
    package.targets.append(target)
    package.products.append(library)
}

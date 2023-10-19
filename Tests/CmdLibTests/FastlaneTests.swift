//
//  FastlaneTests.swift
//  CmdLibTests
//
//  Created by boyer on 2021/12/6.
//

import Quick
import Nimble
import SwiftShell
//import Fastlane
@testable import CmdLib

class FastlaneTests: QuickSpec {
 
    override class func spec() {
        xit("编译静态库到桌面目录") {
            let runner = "/Users/boyer/hsg/iFastlane/Runner"
            let output = try! runAsync(runner, "lane", "buildLib").finish().stdout.read()
            print(output)
        }
        
//        it("版本控制") {
//            let branchname = gitBranch()
//            print("分支名称：\(branchname)")
//        }
//        it("gym方法使用") {
//            let outDir = "/Users/boyer/Desktop/libs"
//            let projPath = "/Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj"
//            gym(project:OptionalConfigValue(stringLiteral:projPath),
//                      scheme: "JHGuessLikesCommodityLibrary",
//             outputDirectory: outDir,
//               configuration: "Debug",
//                skipPackageIpa: .userDefined(true),
//                skipArchive: .userDefined(true)
//            )
//        }
//        xcodebuild -resolvePackageDependencies -scheme JHGuessLikesCommodityListComponent -project /Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj -configuration Debug
//        
//        xcodebuild -showBuildSettings -scheme JHGuessLikesCommodityListComponent -project /Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj -configuration Debug
        
//        xcodebuild -showBuildSettings -scheme JHGuessLikesCommodityLibrary -project /Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj -configuration Debug
    }
}

//
//  File.swift
//  
//
//  Created by boyer on 2022/10/15.
//

import Foundation
import Fastlane

extension Fastfile
{
    func safariLane() {
        //
        desc("使用终端进行单元测试")
        //测试alfred safari查询过程中的问题
//        scan()
        //OptionalConfigValue<Bool?>
        runTests(project: "/Users/boyer/hsg/iFastlane/Runner.xcodeproj",
                 //packagePath: .userDefined("/Users/boyer/hsg/iFastlane/Package.swift"),
                 scheme:"CmdLibTests",
                 device: .userDefined("macosx12.3"),
                 skipDetectDevices: .userDefined(true),
                 //onlyTesting: ["CmdLibTests/PathSpecs"],
                 testplan: .userDefined("/Users/boyer/hsg/iFastlane/swift/Alfred/CmdLibTests.xctestplan"),
                 destination: "platform=macos",
                 catalystPlatform: .userDefined("macos")
//                 buildForTesting: .userDefined(true)
                )
    }
    
    //xcodebuild test -resolvePackageDependencies -scheme CmdLibTests -project /Users/boyer/hsg/iFastlane/Runner.xcodeproj -destination platform=macos

}

//
//  JinherAPP.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane
extension Fastfile
{
    //MARK: 开发者证书
    func JHAppLane() {
        desc("金和APP使用公司证书,实现真机运行")
//        match(type:"development", appIdentifier:["com.jinher.jingquezhili"],teamId:"9CA5KUE8T7")
        gym(//workspace: "YGPatrol.xcworkspace",
              project: "JHUniversalApp.xcodeproj",
               scheme: "JHUniversalApp",
//      outputDirectory: outDir,
        configuration: "Debug",
         exportMethod: "development"
      // exportXcargs: "-allowProvisioningUpdates",
//                  sdk: "iphoneos12.1"  //xcodebuild -showsdks
        )
        installOnDevice(deviceId: OptionalConfigValue("\(plus8)"), ipa: "build/JHUniversalApp.ipa")
        //        uploadPgyer() //发布到蒲公英
        //        iPappLane()   //发布到github
    }
}

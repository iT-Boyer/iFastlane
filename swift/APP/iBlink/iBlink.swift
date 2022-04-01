//
//  iBlink.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane
extension Fastfile
{
    //MARK: 个人证书
    func blinksignLane() {
        automaticCodeSigning(path: "Blink.xcodeproj",useAutomaticSigning:true)
    }
    
    func blinkLane() {
        desc("使用个人账号,实现真机运行")
//        match() //获取证书
        // 证书管理的模式开关
//        automaticCodeSigning(path: "Blink.xcodeproj",useAutomaticSigning:true)
        gym(project: "/Users/boyer/Desktop/blink/Blink.xcodeproj",
            scheme:"Blink",
            outputDirectory: "build",
            configuration: "Debug",
            exportMethod: "development",
            //exportXcargs: "-allowProvisioningUpdates",
            sdk: OptionalConfigValue("\(iossdk)")
        )
        
        installOnDevice(deviceId: OptionalConfigValue("\(ipad)"), ipa: OptionalConfigValue("\(ipaPath)"))
        //发布到蒲公英
        pgyer(apiKey: "318c51ed714a80fa0beab1abc022965b", userKey: "5d4309fb86e31ab180ae6cbdf42f8e2f")
        iPappLane()   //发布到github
    }
    
    //MARK:- 真机运行
    func blinkcerLane() {
       desc("搭建fastlane测试")
       match(teamId:"C556M74S8M",teamName:"Brainhoop Inc.", gitUrl:"https://iTBoyer:jiwangQ3203@gitee.com/iTBoyer/iMatchProfile.git", gitBranch:"master")
       gym(scheme:"Blink",exportTeamId:"C556M74S8M")
       //        installOnDevice(deviceId: plus8, ipa: "build/Blink.ipa")
       installOnDevice(deviceId: OptionalConfigValue("\(ipad)"), ipa: "build/Blink.ipa")
    }
}

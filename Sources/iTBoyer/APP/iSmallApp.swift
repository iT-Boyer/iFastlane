//
//  iSmallApp.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane

extension Fastfile
{
    func iSmallLane() {
//        desc("搭建fastlane测试")
        
        match(teamId: "9CA5KUE8T7",
            teamName: "BEIJING JINHER SOFTWARE CO.LTD.",
              gitUrl: "https://iTBoyer:jiwangQ3203@gitee.com/iTBoyer/iMatchProfile.git",
           gitBranch: "master")
        
        gym(workspace: "../../iSwiftUI.xcworkspace",
              project: nil,
               scheme: "iSmallApp",
         exportMethod: "development",
         exportTeamId: "9CA5KUE8T7")
        
        installOnDevice(deviceId: OptionalConfigValue("\(plus8)"), ipa: "build/iSmallApp.ipa")
    }
}

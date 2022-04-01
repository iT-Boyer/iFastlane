//
//  SupervisionSel.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane
extension Fastfile
{
    //MARK:- 模拟器运行
    func superTestLane() {
        
//        desc("单元测试")
        // scan是run_tests的别名
        scan(workspace: "SupervisionSel.xcworkspace",
                scheme: "SupervisionSel",
             device: OptionalConfigValue("iPhone 11 Pro Max")
//             devices: OptionalConfigValue(arrayLiteral: arr)
            )
    }

    //MARK: 个人证书
    func superInstallLane() {
//        desc("使用个人账号,实现真机运行")
        //iossdk.stringLiteral
        // cocoapods()
        automaticCodeSigning(path: "SupervisionSel.xcodeproj",useAutomaticSigning:true)
        gym(workspace: "SupervisionSel.xcworkspace",
                       scheme: "SupervisionSel",
              outputDirectory: "./build",
                configuration: "Debug",
//                 exportMethod: "development",
//                 exportXcargs: "-allowProvisioningUpdates",
            sdk: OptionalConfigValue("\(iossdk)"))
        
//        installOnDevice(deviceId: ipad, ipa: ipaPath)
//        uploadPgyer() //发布到蒲公英
//        iPappLane()   //发布到github
    }

    
    func superSimLane() {
        
//        desc("在模拟器上运行")
//        let arguments = [
//                         RubyCommand.Argument.init(name: "install", value: "build/SupervisionSel.ipa"),
//                         RubyCommand.Argument.init(name: "--devicetypeid", value: "iPhone 11 Pro Max"),
//                         RubyCommand.Argument.init(name: "--exit", value: "")
//                        ]
////
//        let shellCmd = RubyCommand(commandID: "",
//                                  methodName: "ios-sim",
//                                   className: nil,
//                                        args: arguments)
////
//        _ = runner.executeCommand(shellCmd)
        
    }
}

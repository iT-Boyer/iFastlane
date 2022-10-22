//
//  File.swift
//  
//
//  Created by boyer on 2022/10/21.
//

import Foundation
import Fastlane
import PathKit
/// 演示在github action中实现自动编译，并发布到web浏览器中的流程
extension Fastfile
{
    //MARK:- 模拟器运行
    func swiftTestLane() {
//        desc("单元测试")
        // scan是run_tests的别名
        let file = Path.current.string
        echo(message:"当前位置：\(file)")
        scan(project: "FastlaneDemo.xcodeproj",
             scheme: "FastlaneDemo",
             device: .userDefined("iPhone 11 Pro Max")
        )
    }

    //MARK: 个人证书
    func swiftBuildLane() {
        desc("使用个人账号,实现真机运行")
        // cocoapods()
        automaticCodeSigning(path: "FastlaneDemo.xcodeproj",useAutomaticSigning:true)
        gym(project:"FastlaneDemo.xcodeproj",
            scheme: "FastlaneDemo",
            outputDirectory: "./build",
            configuration: "Debug",
            exportMethod: "development",
            exportXcargs: "-allowProvisioningUpdates" //开启自动签名，xcodebuild默认禁用
//            sdk: .userDefined(iossdk)
        )
        
//        installOnDevice(deviceId: ipad, ipa: ipaPath)
//        uploadPgyer() //发布到蒲公英
//        iPappLane()   //发布到github
        appetizeLane(path: "./build/FastlaneDemo.ipa")
    }

    
    func swiftSimLane() {
        
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

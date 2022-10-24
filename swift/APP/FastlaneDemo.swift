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
            exportXcargs: "-allowProvisioningUpdates", //开启自动签名，xcodebuild默认禁用
           sdk: .userDefined("iphoneos")
        )
        
//        installOnDevice(deviceId: ipad, ipa: ipaPath)
//        uploadPgyer() //发布到蒲公英
//        iPappLane()   //发布到github
        sh(command: "pwd", log: .userDefined(true))
        appetizeLane(path: "./build/FastlaneDemo.ipa")
    }


    func blinkBuildLane() {
        desc("使用blink的编译方式打包测试")
 //   run: set -o pipefail && xcodebuild archive -project FastlaneDemo.xcodeproj -scheme FastlaneDemo -sdk iphoneos -configuration Debug clean build IPHONEOS_DEPLOYMENT_TARGET='15.0' CODE_SIGN_IDENTITY='' CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO | tee build.log | xcpretty
        gym(project: "FastlaneDemo.xcodeproj",
            scheme: "FastlaneDemo",
            clean: true,
            configuration: "Debug",
            exportMethod: "package",
            //skipArchive: .userDefined(true), //跳过打包无法生成app/ipa文件
            skipCodesigning: .userDefined(true), //跳过签名
            buildPath: "./build",
            sdk: "iphoneos"
            ,xcargs: "ONLY_ACTIVE_ARCH=NO"  //添加额外字段，通过xcodebuild --help支持的字段
        )

        let shcmd = """
            cd build    \
            && mkdir Payload \
            && mv ./*/Products/Applications/FastlaneDemo.app Payload/ \
            && zip -r FastlaneDemo.ipa Payload \
            && pwd \
            && cd .. \
            && pwd
            """
        let shhcmd = """
            mkdir Payload
            mv build/*/Products/Applications/FastlaneDemo.app Payload/
            zip -r FastlaneDemo.ipa Payload
"""
        
        let cmdlog = sh(command: shcmd, log: .userDefined(true)) { err in
            print("错误状态：\(err)")
        }
            
        log(message: "开始上传iPA:\(cmdlog)")
//        appetize(apiToken: "tok_wkvivs35obwvkt4pmpyaavj6gu", path: "FastlaneDemo.ipa")
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

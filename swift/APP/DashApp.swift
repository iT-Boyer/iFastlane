//
//  File.swift
//  
//
//  Created by boyer on 2022/10/28.
//

import Foundation
import Fastlane

extension Fastfile
{
    //编译dashapp，使用xcode签名，发布到github，并通过二维码安装app
    func dashLane() {
        automaticCodeSigning(path: "Dash/   Dash iOS.xcodeproj",useAutomaticSigning:true)
        // cocoapods()
        gym(workspace: "Dash iOS.xcworkspace",
            //project:"Dash/Dash iOS.xcodeproj",
            scheme: "Dash",
            outputDirectory: "./build",
            configuration: "Debug",
            exportMethod: "development",
            exportXcargs: "-allowProvisioningUpdates", //开启自动签名，xcodebuild默认禁用
            buildPath: "./build",
            sdk: .userDefined("iphoneos")
        )
        // outDir = iPappDir+"/"+ipaName //\(iPappDir)/\(ipaName)"
        // // iPapp ipaPath ipafileUrl
        // //ipa 包的位置
        // let ipaPath = ".build/Dash.ipa" //\(outDir)/\(ipaName).ipa"
        // sh(command: "\(iPappDir)/iPapp.sh \(ipaPath)", log:true)
        // iPappLane()   //发布到github
    }
    
}

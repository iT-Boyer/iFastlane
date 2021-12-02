//
//  JinherAPP.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane

public let myRepo="https://github.com/it-boyer/PodRepo.git"

extension Fastfile
{
    /// 使用cocoapod工具验证组件源码,并打tag推送至远程库
        /// - Parameter options: 字典
        /// - 使用案例: `fastlane podPushLane version:1.2 project:LogSwift`
        func podPushLane(withOptions options:[String: String]?) {
            desc("升级LogSwift组件私库")
            // add actions here: https://docs.fastlane.tools/actions
            let target_v:String = (options?["version"])!
            let project:String  = (options?["project"])!
            let path:String!     = "\(project).podspec"
            cocoapods()
            let warning:OptionalConfigValue<Bool?> = .userDefined(true)
            podLibLint(allowWarnings:warning)
            versionBumpPodspec(path: path, versionNumber: OptionalConfigValue("\(target_v)"), versionAppendix: nil)  //更新 podspec
            gitCommit(path: [path], message: "Bump version to \(target_v)") //提交版本号修改
            addGitTag(buildNumber: OptionalConfigValue("\(target_v)"))  //设置 tag
            pushToGitRemote(remoteBranch:OptionalConfigValue("\(target_v)")) // 推送到 git 仓库
            //提交到 CocoaPods
            //pod repo push PodRepo 'LogSwift.podspec' --allow-warnings
            let arr = [myRepo]
            podPush(path: OptionalConfigValue("\(path)"), repo: OptionalConfigValue("PodRepo"), allowWarnings: warning, sources: .userDefined(arr))
        }
        
        
        func jazzyLane(withOptions options:[String: String]?) {
            //生成日志
            desc("jazzy生成日志")
            jazzy(config: ".iOS.jazzy.yaml")
    //        jazzy(config: ".osx.jazzy.yaml")
        }
}

//
//  iShell.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane

extension Fastfile
{
    /*/测试不执行
    func shelllane() {
    dotgpgEnvironment(dotgpgFile:"fastlane_gem/.env.default")
    return
    //
    let process = Process()
    let exePath = "/Users/admin/hsg/hexo/GitSubmodules/hsgTool/pngquant/pngquant"
    process.launchPath = exePath //URL.init(fileURLWithPath: exePath)
    process.arguments = ["/admin/hsg/testPng/123.png"]
    process.launch()
    return
    //
    let myAppleScript = """
    on run
    do shell script
    export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=10
    echo $FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT
    end run
    """
    let scriptObject = NSAppleScript(source: myAppleScript);
    scriptObject?.executeAndReturnError(nil)
    }
    */
   ///
//   func rslane() {
//       let shellCmd = RubyCommand.init(commandID: "", methodName: "export", className: nil, args: [])//[RubyCommand.Argument.init(name: "FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT", value: 10),RubyCommand.Argument.init(name: "FASTLANE_XCODEBUILD_SETTINGS_RETRIES", value: 9)])
//       echo(message: "开始---打印环境变量")
//       _ = runner.executeCommand(shellCmd)
//       echo(message: "结束---打印环境变量")
//   }
}

//
//  fastlane+JHBase.swift
//  Runner
//
//  Created by boyer on 2022/4/1.
//

import Foundation
import Fastlane

extension Fastfile
{
    // spm 编译Framework
    //runner lane jhbase name libname
    func jhbaseLane(withOptions options:[String: String]?) {
        
        guard let name = options?["name"], name.count > 0 else {
            echo(message: "非法地址")
            return
        }
        
        spm(command: "build",
            buildPath: "~/Desktop/spm_build",
            packagePath: "~/hsg/\(name)",
            configuration: "release",
            disableSandbox: true,
            xcprettyOutput: "simple",
            xcprettyArgs: "–tap –no-utf",
            verbose: false)
    }
}

//
//  JHBuildSpecs.swift
//  Runner
//
//  Created by boyer on 2022/4/1.
//  
//

import Quick
import Nimble
import Fastlane
@testable import CmdLib
// 编译第三方库为xframework
class JHBuildSpecs: QuickSpec {
    override func spec() {
        describe("库编译工具") {
            
            beforeEach {
                
            }
            
            afterEach {
                
            }
            
            it("使用spm编译工程") {
                //
                Fastlane.spm(command: "build",
                    buildPath: "~/Desktop/spm_build",
                    packagePath: "~/hsg/JHThirdPackage",
                    configuration: "release",
                    disableSandbox: true,
                    xcprettyOutput: "simple",
                    xcprettyArgs: "–tap –no-utf",
                    verbose: false)
            }
            
            xit("制作xcframework") {
                Fastlane.createXcframework(output: "")
            }
            
        }
    }
}

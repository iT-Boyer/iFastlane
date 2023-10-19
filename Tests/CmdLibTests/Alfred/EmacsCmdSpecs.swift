//
//  EmacsCmdSpecs.swift
//  Runner
//
//  Created by boyer on 2022/1/20.
//  
//
import Foundation
import Quick
import Nimble
import SwiftShell

/**
 问题1: alfred无法加载完整的bash环境，导致emacsclient 等命令，必须使用绝对地址
 Alfred 2 Script Environment https://www.alfredforum.com/topic/789-alfred-2-script-environment/
 
 问题2: brew 在不同系统上，安装包的位置不一致，x86系统：/usr/local/bin/ M1系统：/opt/homebrew/bin
 
 初步考虑在alfred下通过bash shell中if语句判断emacsclient的路径位置。但是在alfred不支持echo日志打印，if语句验证有无法使用。
 ```shell
 echo $PATH
 brew
 echo -n "在Intel系统上";

 emacscmd="/usr/local/bin/emacsclient"
 if [ -f $emacscmd ]; then
     echo "在Intel系统上";
     emacscmd=/opt/homebrew/bin/emacsclient;
 fi

 ${emacscmd} -n "~/.dotfiles/pet/cmd.yaml";
 ```
 考虑二：swift脚本开发：使用一门识别环境的语言，applescript等，但最后选择使用swift 配合swift-sh单文件执行，和swiftshell库解决问题。
 考虑三：使用软连接制作替身，在M1 系统中创建usr/local/bin/
 ```
 sudo mkdir -p /usr/local/bin/
 sudo ln -sf /opt/homebrew/bin/emacsclient /usr/local/bine/emacsclient
 ```
 在swift脚本开发中已经可以不是使用，但是第三种，更便于alfred更新，最终选择 第三种方法解决。
 */

class EmacsCmdSpecs: QuickSpec {
    override class func spec() {
        describe("在emacs当前窗口打开文件") {
            
            //命令：在emacs当前窗口打开文件
            ///usr/local/bin/emacsclient -n "~/.dotfiles/pet/cmd.yaml";
            
            var cmdfile:String!
            var filePath:String!
            beforeEach {
                cmdfile = "emacsclient"
                filePath = "~/.dotfiles/pet/cmd.yaml"
                #if arch(arm64)
                    // M1 执行shell
                    cmdfile = "/opt/homebrew/bin/emacsclient"
                #else
                    // x86 执行shell
                    cmdfile = "/usr/local/bin/emacsclient"
                #endif
            }
            
            xit("方式1:Process 失败") { // Process 在加载 cmdfile 失败
                let process = Process()
                //cmdfile = "/usr/local/Cellar/emacs-plus@28/28.0.50/bin/emacsclient"
                process.executableURL = .init(string: cmdfile)
                process.arguments = ["-n",filePath]
                let pipe = Pipe()
                process.standardOutput = pipe

                try! process.run()
                process.waitUntilExit()
            }
            
            it("方式2:swiftShell") {
                let outputstr = try! runAsync(cmdfile,"-n",filePath!).finish().stdout.read()
                print("日志：\(outputstr)")
            }
            
        }
        xdescribe("获取设备信息，判断CPU芯片架构") {
//            判断系统设备
            it("获取设备信息") {
                let process = ProcessInfo.processInfo
                print("""
                      设备信息：
                      \(process.processName)
                      \(process.processIdentifier)
                      \(process.operatingSystemVersionString)
                      \(process.hostName)
                      \(process.userName)
                      \(process.description)
                      """)
            }
            
            it("通过utsname判断") {
                var systemInfo = utsname()
                uname(&systemInfo)
                let machineMirror = Mirror(reflecting: systemInfo.machine)
                let identifier = machineMirror.children.reduce("") { identifier, element in
                    guard let value = element.value as? Int8, value != 0 else { return identifier }
                    return identifier + String(UnicodeScalar(UInt8(value)))
                }
                print("CPU型号：\(identifier)")
                
            }
            
            it("通过 #if arch 判断") {
                
                if Platform.isM1 {
                    print("在M1设备")
                }else{
                    print("在Intel设备")
                }
                struct Platform {
                    static let isSimulator: Bool = {
                        var isSim = false
                        #if arch(i386) || arch(x86_64)
                            isSim = true
                        #endif
                        return isSim
                    }()
                    static let isM1: Bool = {
                        var isM1 = false
                        #if arch(arm64)     //arch(i386) || arch(x86_64)
                            isM1 = true
                        #endif
                        return isM1
                    }()
                }
            }
        }
    }
}

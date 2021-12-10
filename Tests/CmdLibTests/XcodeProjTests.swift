//
//  XcodeProjTests.swift
//  Runner
//
//  Created by boyer on 2021/12/6.
//  
//

import Quick
import Nimble
import XcodeProj
import PathKit
import Regex
import SwiftShell
import SwiftyJSON
@testable import CmdLib

/**
 //1. 获取库名称+lib名
 //2. 查找proj文件：find xcodeproj
 //3. 使用xcodeproj工具，解析，获取target清单
 //4. 得到target
 //5. 调用gym脚本编译，在Desktop/libs得到.a文件
 //6. 归档：移动到最终目录
 //7. copy到主工程，并替换
 */
class XcodeProjTests: QuickSpec {
    override func spec() {
        describe("学习使用XcodeProj工具") {
            var pbxproj:PBXProj!
            beforeEach {
                let runnerDir = Path(#file).parent().parent().parent()
                let path = Path("\(runnerDir)/Runner.xcodeproj")
                let xcodeproj = try! XcodeProj(path: path)
                pbxproj = xcodeproj.pbxproj
            }
            
            it("打印buildsetting 信息") {
                let key = "CURRENT_PROJECT_VERSION"
//                for conf in pbxproj.buildConfigurations{
//                    let version = conf.buildSettings[key]
//                    print("版本号：\(version)")
//                }
                let prefixkey = "GCC_PREFIX_HEADER"
//                for conf in pbxproj.buildConfigurations where conf.buildSettings[prefixkey] != nil {
//                    let prefixPath:String = conf.buildSettings[prefixkey] as! String
//                    print("宏文件：\(prefixPath)")
//                }
                pbxproj.nativeTargets.forEach{ target in
                    if target.name == "Runner" {
                        let configlist:XCConfigurationList = target.buildConfigurationList!
                        //方式一
                        let conf:XCBuildConfiguration! = configlist.configuration(name: "Release")
                        print("\(conf.name)\n宏文件1：\(conf.buildSettings[prefixkey])")
                        //方式二
                        configlist.buildConfigurations.forEach { config in
                            let prefix = config.buildSettings[prefixkey]
                            print("\(config.name)\n宏文件2：\(prefix)")
                        }
                    }
                }
            }
            
            it("打印target相关信息") {
                pbxproj.nativeTargets.forEach{ target in
                    if target.name == "Runner" {
                        print("target名称："+target.name)
//                        pbxproj.buildFiles.forEach { print("\(type(of: $0.file!)) \(String(describing: $0.file!.path))") }
                        
                        let phaseRef = target.buildPhases
                        var sources:PBXSourcesBuildPhase!
                        phaseRef.forEach { phase in
                            if phase is PBXSourcesBuildPhase {
                                sources = phase as? PBXSourcesBuildPhase
                                return
                            }
                        }
                        
                        let frameworks:PBXFrameworksBuildPhase = phaseRef[1] as! PBXFrameworksBuildPhase
                        let depRef = target.dependencies
                        
                        let type = target.productType
                        print("本项目类型：\(type!)")
                        print("本项目依赖了\(depRef.count)个库")
                        let num = sources.files?.count
                        print("本项目包含\(num!)个源文件")
                        //解析源码文件清单
                        let pbfile:PBXBuildFile = sources.files![0]
                        let element:PBXFileElement = pbfile.file!
                        let filename = element.path!
                        let sourceTree:PBXSourceTree = element.sourceTree!
                        print("文件类型：\(String(describing: element))")
                        print("文件名称：\(String(describing: filename))")
                        
                        let group:PBXFileElement = element.parent!
                        print("\(filename)的group目录：\(String(describing: group.path!))")
//                        sources.files?.forEach({ thefile in
//                            print("文件类型：\(thefile.file)")
//                            print("文件路径：\(thefile.file?.name)")
//                        })
                    }
                    
                }
            }
        }
        
        describe("target操作练习：JHPatrolSDK") {
            //源文件+头文件+宏文件
            
            var target:PBXTarget!
            var projPath:Path!
            beforeEach {
                //项目名+target名
                projPath = Path("/Users/boyer/hsg/jhygpatrol/YGPatrol.xcodeproj")
                let targetName = "JHPatrolSDK"
                
                let xcodeProj = try! XcodeProj(path: projPath)
                let pbxproj = xcodeProj.pbxproj
                let targets:[PBXTarget] = pbxproj.targets(named: targetName)
                target = targets[0]
            }
            
            it("获取.m/.h/.pch文件的路径集合") {
                _ = CmdTools.AllfilesOf(target: target, srcPath: projPath.parent())
            }
        }
        
        describe("检查repo目录") {
            var repoName:String!
            beforeEach {
                repoName = "jhygpatrol"
                
            }
            
            it("打印repo目录下的所有工程项目下的target") {
                let repoPath = "/Users/boyer/hsg/\(repoName)/"
                // 使用find命令搜索 xcode项目
                SwiftShell.main.currentdirectory = repoPath
                //忽略目录用法 -path ./.build -prune -o
                //https://cloud.tencent.com/developer/article/1543082
                //https://segmentfault.com/a/1190000022722569
                let findresult = SwiftShell.run(bash: "find . -path ./.build -prune -o -name \"*.xcodeproj\"").stdout
                let dirArr = findresult.split(separator: "\n")
                
                dirArr.forEach { dir in
                    if !dir.hasSuffix("xcodeproj")
                        || dir.contains("Pods")
                        || dir.contains("jinher.app.IntelDecision"){
                        return
                    }
                    let projPath = dir.replacingOccurrences(of: "./", with: repoPath)
                    
                    let projfile = Path(projPath)
                    print("项目路径：\(projfile.parent())")
                    let xcodeproj = try! XcodeProj(path: projfile)
                    let pbxproj = xcodeproj.pbxproj
                    pbxproj.nativeTargets.forEach { target in
                        let type = target.productType
                        if target.productType == .staticLibrary
                        {
                            print("检查\(target.name) 类型：\(type!)")
                        }
                    }
                }
            }
            it("单库检查域名：单个库检查") {
                CmdTools.checkproj(repo: "jhsmallspace")
            }
            
            it("批量检查域名：从清单文件中，批量排查域名替换情况") {
                let ipprojPath = JHSources()+"todo.txt"
                let ipprojlist:String = try! ipprojPath.read()
                let iparr = ipprojlist.split(separator: "\n")
                
                let megit = Path("/Users/boyer/hsg")
                let mygitArr = try! megit.children()
                var repos:[String] = []
                var others:[String] = []
                for git in iparr {
                    var exist = false
                    for dir in mygitArr {
                        if dir.lastComponent == git {
                            exist = true
                            break
                        }
                    }
                    if exist {
                        repos.append(String(git))
                    }else{
                        others.append(String(git))
                    }
                }
                print("正在检查：\(iparr.count)个项目 \n有 \(others.count) 不存在:\(JSON(others))")
                repos.forEach { repo in
                    CmdTools.checkproj(repo: String(repo))
                }
            }
        }
    }
}

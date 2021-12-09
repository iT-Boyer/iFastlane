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
            it("通过目录和lib名称初始化pbxproj") {
                let repo = "iFastlane"
                let libs = ["Runner.a","CmdLib.a"]
                var libDic:[String:String] = [:]
                //拼接路径
                let repoPath = "/Users/boyer/hsg/\(repo)/"
                // 使用find命令搜索 xcode项目
                SwiftShell.main.currentdirectory = repoPath
                //忽略目录用法 -path ./.build -prune -o
                //https://cloud.tencent.com/developer/article/1543082
                //https://segmentfault.com/a/1190000022722569
                let findresult = SwiftShell.run(bash: "find . -path ./.build -prune -o -name \"*.xcodeproj\"").stdout
                let dirArr = findresult.split(separator: "\n")
                
                dirArr.forEach { path in
                    if !path.hasSuffix("xcodeproj") {
                        return
                    }
                    let projpath = path.replacingOccurrences(of: "./", with: repoPath)
                    print("项目路径：\(projpath)")
                    let path = Path(projpath)
                    let xcodeproj = try! XcodeProj(path: path)
                    pbxproj = xcodeproj.pbxproj
                    
                    libs.forEach { libname in
                        pbxproj.nativeTargets.forEach { target in
                            if libname.contains(target.name) {
                                //确定
                                libDic[libname] = projpath
                                return
                            }
                        }
                    }
                }
                print(libDic)
            }
        }
        
        describe("在target源码文件中查询关键字") {
            var srcfiles:[Path] = []
            //头文件+宏文件
            var headers:[Path] = []
            beforeEach {
                //项目名+target名
                let projPath:Path = Path("/Users/boyer/hsg/jhygpatrol/YGPatrol.xcodeproj")
                let srcPath = projPath.parent()
                let target = "JHPatrolSDK"
                
                let xcodeProj = try! XcodeProj(path: projPath)
                let pbxproj = xcodeProj.pbxproj
                let targets:[PBXTarget] = pbxproj.targets(named: target)
                let runner = targets[0]
                
                //获取源文件+头文件
                var sources:PBXSourcesBuildPhase!
                runner.buildPhases.forEach { phase in
                    if phase is PBXSourcesBuildPhase {
                        sources = phase as? PBXSourcesBuildPhase
                        return
                    }
                }
                
                srcfiles = sources.files!.compactMap{ pbfile in
                    let element:PBXFileElement = pbfile.file!
                    let filePath:Path = try! element.fullPath(sourceRoot: projPath.parent())!
                    return filePath
                }
                
                headers = srcfiles.compactMap{ filePath in
                    //判断当是.m 文件时，匹配.h文件，是否存在，添加到源文件数组
                    var pathstr = filePath.string
                    if pathstr.hasSuffix(".m") || pathstr.hasSuffix(".mm"){
                        pathstr.replaceFirst(matching: "\\.m{1,2}$", with: ".h")
                        let fileheader = Path(pathstr)
                        if fileheader.exists {
                            return fileheader
                        }else{
                            print("不存在：\(fileheader)")
                        }
                    }
                    return nil
                }
                
                //添加宏文件
                //获取宏prefix文件
                let configlist:XCConfigurationList = runner.buildConfigurationList!
                let conf:XCBuildConfiguration! = configlist.configuration(name: "Release")
                if let prefix = conf.buildSettings["GCC_PREFIX_HEADER"]{
                    //$(SRCROOT)/YGPatrol/PrefixHeader.pch
                    print("宏文件：\(prefix)")
                    var prefixStr = "\(prefix)"
                    if prefixStr.hasPrefix("$(SRCROOT)/") {
                        prefixStr.replaceFirst(matching: "\\$\\(SRCROOT\\)/", with: "")
                    }
                    let prefixPath = srcPath+Path(prefixStr)
                    if prefixPath.exists {
                        headers.append(prefixPath)
                    }
                }
                
                print("源文件：\(srcfiles.count),头/宏文件：\(headers.count)")
                print("文件:\(headers)")
            }
            
            it("关键字查询行 正则") {
                let keyword = "Runnertexts"
                //方案一
                //cat grep正则 查找
                //替换 sed 替换 写入文件
                
                //方案二
                //1 path.read
                //2 Regex正则输入
                let file1 = srcfiles[0]
                let filetxt:String = try! file1.read()
                print("文件：\(filetxt)")
                let reg = Regex.init(".*(\"api_host|iuooo|ipFile\").*\n",options: [.ignoreCase, .anchorsMatchLines])
                let matchingLines = reg.allMatches(in: filetxt).map {
                    $0.matchedString
                }
                print("在\(file1.lastComponent)中\n匹配到的行：\(matchingLines)")
                
                //3 regex正则替换
                let result = filetxt.replacingFirst(matching: "public", with: "H$1, $2!")
                print(result)

                //4 path.write 更新文件
                try! file1.write(result)
            }
        }
        
        describe("自检git库中静态库源码文件匹配到的行内容") {
            fit("指定库名，检查单个项目") {
                CmdTools.checkproj(repo: "jhsmallspace")
            }
            
            it("从库清单文件中，批量检查") {
                let ipprojPath = Path("/Users/boyer/Desktop/ipfileGit.txt")
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

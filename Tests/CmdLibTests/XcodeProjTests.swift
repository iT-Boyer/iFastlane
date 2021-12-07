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
        xdescribe("学习使用XcodeProj工具") {
            var pbxproj:PBXProj!
            beforeEach {
                let runnerDir = Path(#file).parent().parent().parent()
                let path = Path("\(runnerDir)/Runner.xcodeproj")
                let xcodeproj = try! XcodeProj(path: path)
                pbxproj = xcodeproj.pbxproj
            }
            
            it("打印target相关信息") {
                pbxproj.nativeTargets.forEach{ target in
                    if target.name == "Runner" {
                        print("target名称："+target.name)
//                        pbxproj.buildFiles.forEach { print("\(type(of: $0.file!)) \(String(describing: $0.file!.path))") }
                        let config = target.buildConfigurationList
                        let phaseRef = target.buildPhases
                        let sources:PBXSourcesBuildPhase = phaseRef[0] as! PBXSourcesBuildPhase
                        
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
            fit("通过目录和lib名称初始化pbxproj") {
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
        
        fdescribe("在target源码文件中查询关键字") {
            var srcfiles:[Path] = []
            beforeEach {
                //项目名+target名
                let srcPath = "/Users/boyer/hsg/iFastlane/"
                let target = "Runner"
                let projPath = srcPath+target+".xcodeproj"
                
                let xcodeProj = try! XcodeProj(path: Path(projPath))
                let pbxproj = xcodeProj.pbxproj
                let targets:[PBXTarget] = pbxproj.targets(named: target)
                let runner = targets[0]
                let sources = runner.buildPhases[0] as! PBXSourcesBuildPhase
                let files = sources.files!
                print("文件数：\(files.count)")
//                let pbfile:PBXBuildFile = sources.files![0]
                for buildfile in files {
                    let element:PBXFileElement = buildfile.file!
                    let filePath:Path = try! element.fullPath(sourceRoot: Path(srcPath))!
                    srcfiles.append(filePath)
                }
            }
            
            it("关键字查询行 正则") {
                let keyword = "Runnertexts"
                print("文件:\(srcfiles)")
                //方案一
                //cat grep正则 查找
                //替换 sed 替换 写入文件
                
                //方案二
                //1 path.read
                //2 Regex正则输入
                let file1 = srcfiles[0]
                let filetxt:String = try! file1.read()
                print("文件：\(filetxt)")
                let reg = Regex.init("^(public|let args).*$",options: [.ignoreCase, .anchorsMatchLines])
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
    }
}

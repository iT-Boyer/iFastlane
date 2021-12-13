//
//  Tools.swift
//  Runner
//
//  Created by boyer on 2021/12/3.
//

import Foundation
import SwiftShell
import PathKit
import XcodeProj
import Regex
import SwiftyJSON

public class CmdTools {
    //给两个数组，求：两个数组不相同的元素数组
    static public func arrDiff(arr1:[Substring], arr2:[Substring]) -> [Substring] {
        //转为set集合类型
        let set1 = Set(arr1)
        let set2 = Set(arr2)
        let diff = set1.symmetricDifference(set2)
        return Array(diff)
    }
    
    /// 检查源码库目录下所有的xcodeproj文件，获取源码文件清单，匹配域名字段
    /// - Parameter repo: 库名称
    /// - 根据repo库名：jhygpatrol，拼接为本地路径：~/hsg/jhygpatrol
    static public func checkproj(repo:String)
    {
        //拼接路径
        let repoPath = "/Users/boyer/hsg/\(repo)/"
        // 使用find命令搜索 xcode项目
        SwiftShell.main.currentdirectory = repoPath
        //切换分支
        try! runAsync("git","checkout","pri-deploy-step2").finish()
        // 更新分支
        let outputstr = try! runAsync("git","pull","origin","pri-deploy-step2").finish().stdout.read()
        print("拉去最新源码：\(outputstr)")
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
            let xcodeproj:XcodeProj!
            do {
                xcodeproj = try XcodeProj(path: projfile)
            } catch {
                print("\(projfile)项目无效")
                return
            }
            
            let pbxproj = xcodeproj.pbxproj
            pbxproj.nativeTargets.forEach { target in
                let type = target.productType
                if target.productType == .staticLibrary
                {
                    print("检查\(target.name) 类型：\(type!)")
                    
                    let allFiles = CmdTools.AllfilesOf(target: target,srcPath: projfile.parent())
                    var rusult:[String:JSON] = [:]
                    allFiles.forEach { filePath in
                        //匹配关键字
                        let filetxt:String = try! filePath.read()
//                        print("文件：\(filetxt)")
                        //(\\[.*?api_host)|((=|:).*?iuooo.*/)
                        let reg = Regex(".*(\"api_host|iuooo|ipFile\").*\n",options: [.ignoreCase, .anchorsMatchLines])
                        let matchingLines = reg.allMatches(in: filetxt).compactMap { resul ->String? in
                            var str = resul.matchedString
//                            str.contains("JHUrlStringManager") || str.contains("fullURL(with") || str.contains("domain(for")
                            guard Regex("JHUrlStringManager\\.{0,1}").matches(str) else {
                                // 删除行前空格
                                let space = NSCharacterSet.whitespaces
                                str = str.trimmingCharacters(in: space)
                                if str.hasPrefix("//")
                                    || str.contains("if ([api_host_adm")
                                {
                                    return nil
                                }
                                   return str
                            }
                            return nil
                        }
                        if matchingLines.count > 0 {
//                            print("\(filePath)\n遗留\(matchingLines.count)条")
                            let json = JSON.init(matchingLines)
                            rusult[filePath.string] = json
                        }
                    }
                    if rusult.count > 0 {
                        print("\(rusult)")
                    }else{
                        print("\(target.name):已处理完毕")
                    }
                }
            }
        }
    }
    
    /// 把项目工程添加到指定的workspace现有的分组中，分组必须已经存在。
    /// - Parameters:
    ///   - workspacePath: 目标workspace路径
    ///   - proj: 要添加的proj 文件路径
    ///   - toGroup: 要添加group名
    public static func addProjTo(workspace workspacePath:Path, proj:Path, toGroup:String = "其他") {
        //workspace处理
        let workspace:XCWorkspace = try! XCWorkspace(path: workspacePath)
        let roots = workspace.data.children
        roots.forEach { element in
            if case let XCWorkspaceDataElement.group(second) = element {
                let secondName = second.name!
                if secondName == toGroup {
                    print("二级：\(toGroup) 下:\(second.children.count)个")
                    //添加文件file
                    let location: XCWorkspaceDataElementLocationType = .absolute(proj.string)
                    let file = XCWorkspaceDataFileRef(location: location)
                    let fileElement = XCWorkspaceDataElement.file(file)
                    second.children.append(fileElement)
                }
            }
        }
        try! workspace.write(path: workspacePath)
    }
    
    /// 筛选target下所有文件
    /// - Parameters:
    ///   - target: 指定target实例，依赖XcodeProj库
    ///   - srcPath: 源码根目录
    /// - Returns: 所有文件的Path实例数组
    static func AllfilesOf(target:PBXTarget, srcPath:Path) -> [Path] {
        var srcfiles:[Path] = []
        //头文件+宏文件
        var headers:[Path] = []
        //获取源文件+头文件
        var sources:PBXSourcesBuildPhase!
        target.buildPhases.forEach { phase in
            if phase is PBXSourcesBuildPhase {
                sources = phase as? PBXSourcesBuildPhase
                return
            }
        }
        
        srcfiles = sources.files!.compactMap{ pbfile in
            if pbfile.file == nil {
                return nil
            }
            let element:PBXFileElement = pbfile.file!
            let filePath:Path = try! element.fullPath(sourceRoot: srcPath)!
            let ext = filePath.extension
            if (ext == "mm" || ext == "swift" || ext == "m"){
                return filePath
            }
            return nil
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
        let configlist:XCConfigurationList = target.buildConfigurationList!
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
        return srcfiles+headers
    }
    
    
    /// 获取repo库中，所有的xcodeproj文件路径
    /// - Parameter repo: 库local路径
    /// - Returns: xcodeproj文件路径集合
    public static func AllProjOf(repo:Path) -> [Path]
    {
        let repoProjs = try! repo.recursiveChildren()
        //错误：Generic parameter 'ElementOfResult' could not be inferred
//        repoProjs.compactMap{ proj in
//                                if proj.match("*.xcodeproj") {
//                                    let pp:Path = proj
//                                    return pp
//                                }
//                                return nil
//                                print("\(proj)")
//        }
        //通配符：仅支持对当前目录匹配，无法递归所有目录
//        let pattern = ("**/*.xcodeproj").description
//                            let paths = Path.glob(pattern)
//        let paths = repo.glob(pattern)
//        print("proj文件：\(paths)")
        
        var projArr:[Path] = []
        repoProjs.forEach { proj in
            if proj.match("*.xcodeproj") {
                projArr.append(proj)
            }
        }
        return repoProjs
    }

    // TODO: 给定清单，clone 代码
    // 1. clone
    // 2. pull
    // 3. push
    static func reposAction(repos:[Substring], action:String, branch:String){

        let log = JHSources()+"error.log"
        repos.forEach{ repo in
            print("开始:\(repo) 分支：\(branch)")
            do{
                // TODO: 拼接路径
                //  pull / push
                if action == "push" || action == "pull"{
                    //开始更新
                    let repoPath = Path.home+"hsg"+String(repo)
                    SwiftShell.main.currentdirectory = repoPath.string
                    let out = try runAsync("git",action,"origin",branch).finish().stdout.read()
                    print("push结果：\(out)")
                }else{
                    // TODO: 获取git远程路径
                    // clone
                    let allLinks = try! (JHSources()+"all_link_path.h").read().split(separator: "\n")
                    SwiftShell.main.currentdirectory = (Path.home+"hsg").string
                    for link in allLinks
                    {
                        if link.contains(repo)
                        {
                            let out = try runAsync("git",action,link).finish().finish().stdout.read()
                            SwiftShell.run(bash: "echo \(out) >> \(log.string)")
                            print("clone结果：\(out)")
                        }
                    }
                }
            }catch{
                let err = "\(repo)：更新失败 \(error.localizedDescription)"
//                SwiftShell.run("echo \(err) >> \(log.string)")
                SwiftShell.run(bash: "echo \(err) >> \(log.string)")
//                print("\(repo)：更新失败 \(error.localizedDescription)")
            }
        }
    }
}

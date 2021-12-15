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

// MARK: CmdTools文件处理工具
public class CmdTools {
    //给两个数组，求：两个数组不相同的元素数组
    /// 求两个数组的差集
    /// - Parameters:
    ///   - arr1: [一个数组]
    ///   - arr2: [一个数组]
    ///   - returns: [返回差集]
    static public func arrDiff(arr1:[Substring], arr2:[Substring]) -> [Substring] {
        //转为set集合类型
        let set1 = Set(arr1)
        let set2 = Set(arr2)
        let diff = set1.symmetricDifference(set2)
        return Array(diff)
    }
    
    /// 检查源码库目录下所有的xcodeproj文件，获取源码文件清单，匹配域名字段
    /// - Parameters:
    ///   - repo: 库名称
    ///   - 根据repo库名：jhygpatrol，拼接为本地路径：~/hsg/jhygpatrol
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
//            let allTargets = CmdTools.targetsOf(proj: projfile)
            let pbxproj = xcodeproj.pbxproj
            pbxproj.nativeTargets.forEach { target in
                print("检查\(target.name) 类型：\(String(describing: target.productType!))")
                
                let allFiles = CmdTools.AllfilesOf(target: target,srcPath: projfile.parent())
                var rusult:[String:JSON] = [:]
                allFiles.forEach { filePath in
                    //匹配关键字
                    let filetxt:String
                    do {
                      filetxt = try filePath.read()
                    } catch {
                        print("\(filePath.lastComponent)文件read()打开失败")
                        return
                    }
//                        print("文件：\(filetxt)")
                    //(\\[.*?api_host)|((=|:).*?iuooo.*/)
                    let reg = Regex(".*(\"api_host|iuooo|ipFile\").*\n",options: [.ignoreCase, .anchorsMatchLines])
                    let matchingLines = reg.allMatches(in: filetxt).compactMap { resul ->String? in
                        var str = resul.matchedString
                        guard Regex("JHUrlStringManager\\.{0,1}|JHBaseDomain|GeneralUtil|JinherUploadCenterApi|HttpIpFileService|NetEngine").matches(str) else {
                            // 删除行前空格
                            let space = NSCharacterSet.whitespaces
                            str = str.trimmingCharacters(in: space)
                            if str.hasPrefix("//")
                                || str.contains("if ([api_host_adm")
                                || str.contains("update.iuoooo.com")
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
    
    /// 把项目工程添加到指定的workspace现有的分组中，分组必须已经存在。
    /// - Parameters:
    ///   - workspacePath: 目标workspace路径
    ///   - proj: 要添加的proj 文件路径
    ///   - toGroup: 要添加group名
    public static func addProjTo(workspace workspacePath:Path, proj:Path, toGroup:String = "其他") {
        //workspace处理
        let workspace:XCWorkspace = try! XCWorkspace(path: workspacePath)
        let roots = workspace.data.children

        func fileElement()->XCWorkspaceDataElement{
            //添加文件file
            let location: XCWorkspaceDataElementLocationType = .absolute(proj.string)
            let filePath = XCWorkspaceDataFileRef(location: location)
            let file = XCWorkspaceDataElement.file(filePath)
            return file
        }
        
        func groupElement()->XCWorkspaceDataElement{
            let groupLocation: XCWorkspaceDataElementLocationType = .absolute(JHSources().string)
            let childrens = [fileElement()]
            let groupData = XCWorkspaceDataGroup(location: groupLocation,
                                             name: toGroup,
                                             children: childrens)
            let group = XCWorkspaceDataElement.group(groupData)
            return group
        }

        // 判断组是否存在
        var exist = false
        roots.forEach { element in
            if case let XCWorkspaceDataElement.group(second) = element {
                let secondName = second.name!
                if secondName == toGroup {
                    exist = true
                    print("二级：\(toGroup) 下:\(second.children.count)个文件")
                    let fileElement = fileElement()
                    second.children.append(fileElement)
                    //添加完成退出循环
                    return
                }
            }
        }

        if !exist {
            //TODO: 添加组
            let newGroup = groupElement()
            workspace.data.children.append(newGroup)
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
        //info.plist文件
        var infos:[Path] = []
        //获取源文件+头文件
        var sources:PBXSourcesBuildPhase!
        var resources:PBXResourcesBuildPhase!
        target.buildPhases.forEach { phase in
            switch phase {
            case is PBXSourcesBuildPhase:
                sources = phase as? PBXSourcesBuildPhase
            case is PBXResourcesBuildPhase:
                resources = phase as? PBXResourcesBuildPhase
            default:
                _ = ""
            }
        }
        if target.productType == .bundle {
            infos = resources.files!.compactMap{ buildFile in
                if buildFile.file == nil {
                    return nil
                }
                let element:PBXFileElement = buildFile.file!
                if let filePath = try! element.fullPath(sourceRoot: srcPath){
                    let ext = filePath.extension
                    if (ext == "plist"){
                        return filePath
                    }
                }
                return nil
            }
        }
    
        if target.productType == .staticLibrary {
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
        }
        
        print("源文件：\(srcfiles.count),头/宏文件：\(headers.count),info.plist文件：\(infos.count)")
        return srcfiles+headers+infos
    }
    
    /// 获取repo库中，所有的xcodeproj文件路径
    /// - Parameter
    /// - repo: 库local路径:~/hsg/jhygpotrol
    /// - Returns: xcodeproj文件路径集合
    public static func AllProjOf(repo:Path) -> [Path]
    {
        if !repo.exists {
            print("\(repo)文件不存在")
            return []
        }
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
        return projArr
    }

    /// 获取xcodeproj文件中所有的静态库target 名称数组
    /// - Parameter proj: 库xcodeproj路径
    /// - Returns: 静态库名称数组
    public static func targetsOf(proj:Path)->[PBXNativeTarget]{

        print("项目路径：\(proj.parent())")
        let xcodeproj:XcodeProj!
        do {
            xcodeproj = try XcodeProj(path: proj)
        } catch {
            print("\(proj)项目无效")
            return []
        }
        let pbxproj = xcodeproj.pbxproj
        let staticLibs = pbxproj.nativeTargets.compactMap{ target->PBXNativeTarget? in
            if target.productType == .staticLibrary
                || target.productType == .bundle
            {
                return target
            }
            return nil
        }
        return staticLibs
    }
    public static func createScheme(projPath:Path,target:PBXNativeTarget){
        if target.productType == .bundle {
            print("不支持bundle文件：\(target.name)")
            return
        }
        let uuid = target.uuid
        //
        let schemeDir = projPath+"xcshareddata/xcschemes"
        let schemePath = schemeDir+"\(target.name).xcscheme"
        if schemePath.exists{
            print("\(target.name).scheme已存在,不需要新建")
            return
        }
        SwiftShell.run(bash: "mkdir -p \(schemeDir.string)")
        let buildRef = XCScheme.BuildableReference.init(referencedContainer: "container:\(projPath.lastComponent)",
                                                        blueprintIdentifier: uuid,
                                                        buildableName: "lib\(target.name).a",
                                                        blueprintName: target.name)
        let entry = XCScheme.BuildAction.Entry.init(buildableReference: buildRef,
                                                    buildFor: XCScheme.BuildAction.Entry.BuildFor.default)
        let buildAction = XCScheme.BuildAction.init(buildActionEntries: [entry],
                                                    preActions: [],
                                                    postActions: [],
                                                    parallelizeBuild: true,
                                                    buildImplicitDependencies: false,
                                                    runPostActionsOnFailure: false)

        let testAction = XCScheme.TestAction.init(buildConfiguration: "Debug",
                                                   macroExpansion: buildRef,
                                                  selectedDebuggerIdentifier: "Xcode.DebuggerFoundation.Debugger.LLDB",
                                                  selectedLauncherIdentifier: "Xcode.DebuggerFoundation.Launcher.LLDB",
                                                  shouldUseLaunchSchemeArgsEnv: true
                                                )
        let profileAction = XCScheme.ProfileAction.init(buildableProductRunnable:nil,//  XCScheme.BuildableProductRunnable?,
                                                        buildConfiguration: "Debug",
                                                        preActions: [],
                                                        postActions: [],
                                                        macroExpansion: buildRef,
                                                        shouldUseLaunchSchemeArgsEnv: true,
                                                        savedToolIdentifier: "",
                                                        useCustomWorkingDirectory: false,
                                                        debugDocumentVersioning: true,
                                                        askForAppToLaunch: false,
                                                        commandlineArguments: nil,
                                                        environmentVariables: nil,
                                                        enableTestabilityWhenProfilingTests: false)
        let scheme = XCScheme.init(name: target.name,
                                   lastUpgradeVersion: "1.0",
                                   version: "1.0",
                                   buildAction:buildAction,
                                   testAction: testAction,
                                   launchAction: nil,
                                   profileAction: profileAction,
                                   analyzeAction: nil,
                                   archiveAction: nil,
                                   wasCreatedForAppExtension: true)
        try! scheme.write(path: schemePath, override: true)
    }
    
    // TODO: 给定清单，clone 代码
    // 1. clone
    // 2. pull
    // 3. push
    
    /// 下载，更新，push 库
    /// - Parameters:
    ///   - repos: 批量处理的库名清单文件/存储在hsg/目录下
    ///   - action: 支持clone pull push 三种命令
    ///   - branch: 指定分支名
    public static func reposAction(repos:[Substring], action:String, branch:String){
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
                    print("\(action)结果：\(out)")
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

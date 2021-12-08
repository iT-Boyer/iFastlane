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
    
    //读取proj文件
    func loadProj(proj:String)
    {
        //新建proj
        let runnerDir = Path(#file).parent().parent()
        
        let path = Path("\(runnerDir)/Runner.xcodeproj") // Your project path
        let xcodeproj = try! XcodeProj(path: path)
        let pbxproj = xcodeproj.pbxproj // Returns a PBXProj
        pbxproj.nativeTargets.forEach{ target in
            print("target名称："+target.name)
        }
        pbxproj.buildFiles.forEach { print("\(type(of: $0.file!)) \(String(describing: $0.file!.path))") }
//        //
//        let project = pbxproj.projects.first!
//        let mainGroup = project.mainGroup
//        try! mainGroup?.addGroup(named: "MyGroup")
//
////        #向group中增加文件引用（.h文件只需引用一下，.m引用后还需add一下）
////        let file_ref = group.new_reference('xxxPath/xx.h')
//
//        let file_path = Path("/test/test.swift")
//        let sourceRoot = Path("/test/sources")
//        try! mainGroup?.addFile(at: file_path, sourceRoot: sourceRoot)
//
//        try! xcodeproj.write(path: path)
    }
    
    //获取git路径
    func printGitUrl(arr:[String]) {
        //swiftshell 加载文件
        for name in arr {
            let home = "/Users/boyer/hsg/"+name
            SwiftShell.main.currentdirectory = home
            do{
                let output = try runAsync("git","remmote","-v").finish().stdout.read()
                let pushs = output.split(separator: "\n")
                print(pushs[0])
            }catch
            {
                print("\(name)：无权限")
            }
        }
    }
    
    func pushGitUrl(arr:[String],msg:String) {
        for name in arr {
            let home = "/Users/boyer/hsg/"+name
            SwiftShell.main.currentdirectory = home
            do {
                let output = try runAsync("git","push","origin","pri-deploy-step2").finish().stdout.read()
//                let push = output.split(separator: "\n")
                print(output)
            } catch {
                print("\(name)：无权限")
            }
        }
    }
    
    //通过lib.a文件清单获取proj字典
    static public func checkproj(repo:String)
    {
        //拼接路径
        let repoPath = "/Users/boyer/hsg/\(repo)/"
        // 使用find命令搜索 xcode项目
        SwiftShell.main.currentdirectory = repoPath

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
                    //获取宏prefix文件
                    let configlist:XCConfigurationList = target.buildConfigurationList!
                    let conf:XCBuildConfiguration! = configlist.configuration(name: "Release")
                    if let prefix = conf.buildSettings["GCC_PREFIX_HEADER"]{
                        print("宏文件：\(prefix)")
                    }
                    
                    
                    let phaseRef = target.buildPhases
                    var sources:PBXSourcesBuildPhase!
                    phaseRef.forEach { phase in
                        if phase is PBXSourcesBuildPhase {
                            sources = phase as? PBXSourcesBuildPhase
                            return
                        }
                    }
//                    let sources:PBXSourcesBuildPhase = phaseRef[0] as! PBXSourcesBuildPhase
                    let files = sources.files!
                    print("包含\(files.count)个源文件")
                    for buildfile in files {
                        if buildfile.file == nil {
                            continue
                        }
                        let element:PBXFileElement = buildfile.file!
                        let filePath:Path = try! element.fullPath(sourceRoot: projfile.parent())!
                        //.m.h   .swift
                        
                        let filetxt:String = try! filePath.read()
//                        print("文件：\(filetxt)")
                        //(\\[.*?api_host)|((=|:).*?iuooo.*/)
                        let reg = Regex(".*(\"api_host|iuooo|ipFile\").*\n",options: [.ignoreCase, .anchorsMatchLines])
                        let matchingLines = reg.allMatches(in: filetxt).compactMap { resul ->String? in
                            var str = resul.matchedString
                            guard str.contains("JHUrlStringManager") else {
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
                            let json = JSON.init(matchingLines)
                            print("\(filePath)\n遗留\(matchingLines.count)条\n\(json)")
                        }
                    }
                }
            }
        }
    }
}

func runnerPath() -> Path {
    Path(#file).parent()
}

func iosProjectDictionary() -> (Path, [String: Any]) {
    let iosProject = runnerPath() + "Runner.xcodeproj/project.pbxproj"
    return (iosProject, loadPlist(path: iosProject.string)!)
}

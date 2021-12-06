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

public class CmdTools:NSObject {
    //给两个数组，求：两个数组不相同的元素数组
    public func arrDiff(arr1:[Substring], arr2:[Substring]) -> [Substring] {
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
}

func runnerPath() -> Path {
    Path(#file).parent()
}

func iosProjectDictionary() -> (Path, [String: Any]) {
    let iosProject = runnerPath() + "Runner.xcodeproj/project.pbxproj"
    return (iosProject, loadPlist(path: iosProject.string)!)
}

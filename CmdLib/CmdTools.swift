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
                            guard Regex("JHUrlStringManager\\.{0.1}").matches(str) else {
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
}

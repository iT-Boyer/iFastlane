//
//  JinheLib.swift
//  Runner
//
//  Created by boyer on 2021/12/6.
//

import Foundation
import Fastlane
import PathKit
import SwiftyJSON
import CmdLib

extension Fastfile
{
    //编译静态库，指定生成路径
    //xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphonesimulator
    func buildLibLane(projPath:String,target:String) {
        let outDir = "/Users/boyer/Desktop/libs"
//        let projPath = "/Users/boyer/hsg/jhgsguesslikeshoppinglistcomponent/JHGuessLikesCommodityListComponent/JHGuessLikesCommodityListComponent.xcodeproj"
        gym(project:.userDefined(projPath),
                  scheme: "\(target)",
         outputDirectory: outDir,
           configuration: "Debug",
//          skipPackageIpa: .userDefined(true),
             skipArchive: .userDefined(true),
         skipCodesigning: .userDefined(true),
            buildPath: .userDefined(outDir), //The directory in which the archive should be stored in
         derivedDataPath: .userDefined(outDir)
        )
    }
    
    
    //1. 获取库名称+lib名
    //2. 查找proj文件：find xcodeproj
    //3. xcodeproj工具，解析，获取target清单
    //4. 得到target
    //5. 调用gym脚本编译，在Desktop/libs得到.a文件
    //6. 归档：移动到最终目录
    //7. copy到主工程，并替换
    // 已自检
    //    1. iuoooo.com & api_host_*
    //    2. ipFile.plist & ipServiceFile.plist
    //    3. 域名的宏替换
    //    4. 其他 plist 配置文件
    // runner lane checkLib repo test
    func checkLibLane(withOptions options: [String : String]?)
    {
        if let value = options?["repo"], value.count > 0
        {
            CmdTools.checkproj(repo: value)
        }
    }
    //runner lane checkAllLibs list filePath
    //runner lane checkAllLibs list ~/Desktop/ipfileGit.txt
    func checkAllLibsLane(withOptions options: [String : String]?) {
        if let value = options?["list"], value.count > 0
        {
            let ipprojPath = Path(value)
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



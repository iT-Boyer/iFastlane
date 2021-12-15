//
//  JinherLib.swift
//  Runner
//
//  Created by boyer on 2021/12/15.
//

import Foundation
import Fastlane
import PathKit
import SwiftyJSON
import CmdLib

//MARK: 金和库
extension Fastfile
{
    
    /// 编译静态库，实现指定生成路径
    /// - Parameters:
    ///   - projPath: xcodeproj文件路径
    ///   - target: target名称
    ///  runner lane buildLib projPath ..xcodeproj target libname
    ///   - 参考：xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphonesimulator
    func buildLibLane(withOptions options: [String : String]?) {
        if let projPath = options?["projPath"], projPath.count > 0,let target = options?["target"]
        {
            let outDir = "/Users/boyer/Desktop/libs"
            do{
                gym(project:.userDefined(projPath),
                    scheme: "\(target)",
                    outputDirectory: outDir,
                    configuration: "Debug",
                    //          skipPackageIpa: .userDefined(true),
                    skipArchive: .userDefined(true),
                    skipCodesigning: .userDefined(true),
                    buildPath: .userDefined(outDir),    //The directory in which the archive should be stored in
                    derivedDataPath: .userDefined(outDir)
                )
            }catch{
                let msg = "\(projPath) \n \(target)"
                sh(command: "echo \(msg) >> ~/Desktop/buildError.log")
            }

        }
    }

    /// 批量编译清单文件下的项目文件中的target
    /// - Parameters:
    ///    - file: 路径 abcheck.txt
    ///- 命令： runner lane buildTargets file 清单文件
    func buildTargetsLane(withOptions options: [String : String]?)
    {
        if let value = options?["file"], value.count > 0
        {
            let repolist = try! Path("\(value)").read().split(separator: "\n")
            repolist.forEach{repo in
                let repoPath = root().parent()+String(repo)
                buildRepoLane(withOptions: ["path":repoPath.string])
            }
        }
    }
    /// 批量编译清单文件下的项目文件中的target
    /// - Parameters:
    ///     - path: 路径 hsg/jhygpatrol/
    /// - 命令：runner lane buildRepo path repopath
    func buildRepoLane(withOptions options: [String : String]?)
    {
        if let value = options?["path"], value.count > 0
        {
            let repoPath = Path("\(value)")
            if repoPath.exists{
                //更新代码
                let reponame = repoPath.lastComponent
                CmdTools.reposAction(repos: reponame.split(separator: ";"), action: "pull", branch: "pri-deploy-step2")
                let projArr = CmdTools.AllProjOf(repo: repoPath)
                // print("projArr: \(projArr)")
                projArr.forEach{projPath in
                    let targets = CmdTools.targetsOf(proj: projPath)
                    targets.forEach{target in
                        if target.productType == .staticLibrary {
                            CmdTools.createScheme(projPath: projPath, target: target)
                            buildLibLane(withOptions: ["projPath":projPath.string,"target":target.name])
                        }
                    }
                }
            }else{
                print("不存在的目录: \(repoPath)")
            }
        }
    }

    /// 检查单个库中域名替换的情况
    /// - Parameter options: 库名称
    /// - 用法例子：runner lane checkLib repo test
    func checkLibLane(withOptions options: [String : String]?)
    {
        if let value = options?["repo"], value.count > 0
        {
            CmdTools.checkproj(repo: value)
        }
    }

    /// 检索库清单库目录，检查域名替换的情况
    /// - Parameter options: 库名称清单文件路径
    /// - 用法例子：runner lane checkLibs listpath ~/Desktop/checklist.txt
    func checkLibsLane(withOptions options: [String : String]?) {
        if let value = options?["listpath"], value.count > 0
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
    
    
    /// 通过项目库清单文件，向workspace中的分组中添加项目工程引用
    /// - Parameter options:
    ///     - work: workspace路径
    ///     - list: 项目库清单文件
    ///     - group: 分组名
    func addProjLane(withOptions options: [String : String]?)  {
        
        if let work = options?["work"], let list = options?["list"],
           let group = options?["work"]
        {
            let workspacePath = Path(work)
            let abCheckPath:Path = Path(list)
            let abCheck:String = try! abCheckPath.read()
            let abChecklist = abCheck.split(separator: "\n")
            abChecklist.forEach { repo in
                let arr = CmdTools.AllProjOf(repo: root().parent()+"\(repo)")
                arr.forEach { path in
                    CmdTools.addProjTo(workspace: workspacePath, proj: path, toGroup: group)
                }
            }
        }
    }
}



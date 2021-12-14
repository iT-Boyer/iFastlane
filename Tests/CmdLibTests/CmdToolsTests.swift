//
//  ToolsTests.swift
//  RunnerTests
//
//  Created by boyer on 2021/12/3.
//
import XCTest
import Quick
import Nimble
import XcodeProj
import PathKit
import SwiftShell
import SwiftyJSON
@testable import CmdLib

//https://github.com/Quick/Quick/blob/main/Documentation/zh-cn/NimbleAssertions.md
class CmdToolsTests: QuickSpec {
    override func spec() {
        it("求差集") {
            //
            let arr1 = "1,2,3".split(separator: ",")
            let arr2 = "3,4,5".split(separator: ",")
            let arr = CmdTools.arrDiff(arr1: arr1, arr2: arr2)
            let exparr = ["2", "1", "5", "4"]
            print("预期结果：\(exparr) \n实际输入：\(arr[1]) \n\(arr)" )
            expect(arr).toNot(contain(arr[0]))
            
            //案例
            expect(1 + 1).to(equal(4))
            expect(1.2).to(beCloseTo(1.1, within: 0.1))
            expect(3) > 2
            expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
        }
        
        describe("repo库管理：clone,pull,push") {
            it("push测试") {
                let repos = try! (JHSources()+"done.txt").read().split(separator: "\n")
                CmdTools.reposAction(repos: repos, action: "push", branch: "pri-deploy-step2")
            }
            it("clone测试") {
                let repos = try! (JHSources()+"remote.txt").read().split(separator: "\n")
                CmdTools.reposAction(repos: repos, action: "clone", branch: "pri-deploy-step2")
            }
        }
        
        fdescribe("workspac中添加项目") {
            it("通过库名清单，添加到YGPatrol的 其他 分组") {
                let workspacePath = Path("/Users/boyer/hsg/jhygpatrol/YGPatrol.xcworkspace")
                let abCheckPath:Path = JHSources()+"abcheck.txt"
                let abCheck:String = try! abCheckPath.read()
                let abChecklist = abCheck.split(separator: "\n")
//                            print("正在添加文件\(abdonelist)")
                abChecklist.forEach { repo in
                    let arr = CmdTools.AllProjOf(repo: root().parent()+"\(repo)")
                    arr.forEach { path in
                        CmdTools.addProjTo(workspace: workspacePath, proj: path, toGroup: "ABCheck")
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
                let repoPath = "/Users/boyer/hsg/\(String(describing: repoName))/"
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
            xit("单库检查域名：单个库检查") {
                CmdTools.checkproj(repo: "jhsmallspace")
            }
            
            it("批量检查域名：从清单文件中，批量排查域名替换情况") {
                let ipprojPath = JHSources()+"abcheck.txt"
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

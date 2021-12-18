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
import Foundation
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
        
        describe("Path 创建folder") {
            it("创建folder目录") {
                let test = Path.home+"Desktop/test/test/test.txt"
                try! test.makeIterator()
                try! test.write("other")
            }
        }
        
        describe("workspace使用") {
            var workspace:XCWorkspace!
            var workspacePath:Path!
            beforeEach {
                workspacePath = Path("/Users/boyer/hsg/jhygpatrol/YGPatrol.xcworkspace")
                workspace = try! XCWorkspace(path: workspacePath)
            }
            
            it("生成xcscheme") {
                ///"container:UserExtendMessage.xcodeproj"
                ///https://kemchenj.github.io/2018-06-03/
//                let decoder = XcodeprojPropertyListDecoder()
//                let plistDecoder = PropertyListDecoder()
//                let blueprint =  try! PBXObject(from: plistDecoder)
//                let buildRef = XCScheme.BuildableReference.init(referencedContainer: "UserExtendMessage.xcodeproj",
//                                                                blueprint: blueprint,
//                                                                buildableName: "libUserExtendInfomation.a",
//                                                                blueprintName: "UserExtendInfomation")
                
                let projPath = Path.home + Path("hsg/userentermessage/UserExtendMessage/UserExtendMessage.xcodeproj")
                let xcodeproj = try! XcodeProj(path: projPath)
                let pbxproj = xcodeproj.pbxproj
                let target = pbxproj.nativeTargets[1]
                let uuid = target.uuid
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
                
                let schemePath = projPath+"xcshareddata/xcschemes/\(target.name).xcscheme"
                try! scheme.write(path: schemePath, override: true)
            }
            
            it("添加proj到workspaces") {
                //
                print("childen:\(workspace.data.children.count)")
                let roots = workspace.data.children
                roots.forEach { element in
                    if case let XCWorkspaceDataElement.group(second) = element {
                        let secondName = second.name!
                        if secondName == "其他" {
                            print("二级：\(second.name!) 下:\(second.children.count)个")
                            second.children.forEach { proj in
                                if case let XCWorkspaceDataElement.file(third) = proj {
                                    //../WithoutWorkspace/WithoutWorkspace.xcodeproj
                                    let thirdName:XCWorkspaceDataElementLocationType = third.location
//                                    print("类型：\(thirdName.schema) \n\(thirdName.path)")
                                }
                            }
                            //加入新的proj
                            //添加group
                            let groupLocation: XCWorkspaceDataElementLocationType = .absolute(JHSources().string)
                            let group = XCWorkspaceDataGroup(location: groupLocation,
                                                             name: "JHSourcesX",
                                                             children: [])
                            let groupelement = XCWorkspaceDataElement.group(group)
                            
                            second.children.append(groupelement)
                            
                            //添加文件file
                            let proj = root()+"Runner.xcodeproj"
                            let location: XCWorkspaceDataElementLocationType = .absolute(proj.string)
                            let file = XCWorkspaceDataFileRef(location: location)
                            let fileElement = XCWorkspaceDataElement.file(file)
                            second.children.append(fileElement)
                        }
                    }
                }
            }
            afterEach {
                try! workspace.write(path: Resources()+"Test.xcworkspace")
            }
        }
        
        describe("学习使用XcodeProj工具") {
            var pbxproj:PBXProj!
            beforeEach {
                let runnerDir = Path(#file).parent().parent().parent()
                let path = Path("\(runnerDir)/Runner.xcodeproj")
                print("项目路径：\(path.parent())")
                let xcodeproj:XcodeProj!
                do {
                    xcodeproj = try XcodeProj(path: path)
                } catch {
                    print("\(path)项目无效")
                    return
                }
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
                        //Target属性
                        let uuid = target.uuid
                        print("本项目uuid：\(uuid)")
                        let type = target.productType
                        print("本项目类型：\(type!)")
                        
                        /// buildRules 源码属性 依赖
                        let phaseRef = target.buildPhases
                        let depRef = target.dependencies
                        print("本项目依赖了\(depRef.count)个库")
                        
                        var sources:PBXSourcesBuildPhase! //源码
                        var frameworks:PBXFrameworksBuildPhase! //依赖
                        var resources:PBXResourcesBuildPhase!
                        phaseRef.forEach { phase in
                            switch phase {
                            case is PBXFrameworksBuildPhase:
                                frameworks = phase as? PBXFrameworksBuildPhase
                            case is PBXSourcesBuildPhase: //解析源码文件清单
                                sources = phase as? PBXSourcesBuildPhase
                                let num = sources.files?.count
                                print("本项目包含\(num!)个源文件")
                                let pbfile:PBXBuildFile = sources.files![0]
                                let element:PBXFileElement = pbfile.file!
                                let filename = element.path!
//                                let group:PBXFileElement = element.parent!
//                                let sourceTree:PBXSourceTree = element.sourceTree!
//                                print("文件类型：\(String(describing: element))")
                                print("文件名称：\(String(describing: filename))")
//                                print("\(filename)的group目录：\(String(describing: group.path!))")
                            case is PBXResourcesBuildPhase: //解析资源文件清单
                                resources = phase as? PBXResourcesBuildPhase
                                let num = resources.files?.count
                                print("本项目包含\(num!)个源文件")
                                resources.files?.forEach { buildfile in
                                    let element:PBXFileElement = buildfile.file!
                                    let filename = element.path!
//                                    let group:PBXFileElement = element.parent!
//                                    let sourceTree:PBXSourceTree = element.sourceTree!
//                                    print("文件类型：\(String(describing: element))")
                                    print("文件名称：\(String(describing: filename))")
//                                    print("\(filename)的group目录：\(String(describing: group.path!))")
                                }
                            default:
                                print("")
                            }
                        }
                    }
                    
                }
            }
        }
        
        fdescribe("学习SwiftPM依赖的管理") {
            
            var xcodeprj:XcodeProj!
            var prjPath:Path!
            var pbxproj:PBXProj!
            beforeEach {
                prjPath = Path.home+"hsg/ihacking/iHacker/iHacker.xcodeproj"
                print("项目路径：\(prjPath.parent())")
                do {
                    xcodeprj = try XcodeProj(path: prjPath)
                    pbxproj = xcodeprj.pbxproj
                } catch {
                    print("\(String(describing: prjPath))项目无效")
                    return
                }
            }
            fit("更新Proj项目中的SwiftPM依赖设置") {
                let project = try! pbxproj!.rootProject() // Returns a PBXProject
                // When
                let packagePath = Path("../RemoteImageView")
                //XCSwiftPackageProductDependency
                _ = try project!.addLocalSwiftPackage(path: packagePath,
                                                      productName: "RemoteImageView",
                                                      targetName: "iHacker")
                
                print("targ路径："+prjPath.string)
                try! xcodeprj.write(path: prjPath, override: true)
            }
            xit("更新Proj项目中的SwiftPM依赖设置") {
                
                var pbxproj:PBXProj = xcodeprj.pbxproj
                let project = try! pbxproj.rootProject() // Returns a PBXProject
                
                // When
                let packagePath = Path("../JHThirdPackage")
                //XCSwiftPackageProductDependency
                let libs = ["Alamofire","Moya","SwiftyJSON","SnapKit","Kingfisher",
                            "SwifterSwift","CSQLite","ESPullToRefresh","IQKeyboardManagerSwift"]
                for lib in libs{
                    _ = try project!.addLocalSwiftPackage(path: packagePath,
                                                                    productName: lib,
                                                                     targetName: "Runner")
                }
                
                let targ = Path("~/hsg/iFastlane/Runner.xcodeproj")
                print("targ路径："+targ.string)
                try! xcodeprj.write(path: targ, override: true)
            }
        }
    }
}

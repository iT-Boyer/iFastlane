//
//  JinheTests.swift
//  Runner
//
//  Created by boyer on 2021/12/16.
//  
//

import Quick
import Nimble
import Foundation
import PathKit
@testable import CmdLib

class JinheTests: QuickSpec {
    override func spec() {
        describe("演示JSONDecoder工具") {
            fit("解析iu平台的菜单清单json文件") {
                let jsonPath = JHSources()+"iu-menu.json"
                let jsonData = try! jsonPath.read()
                let jsonDecoder = JSONDecoder()
                let model = try! jsonDecoder.decode(IUMenuModel.self, from: jsonData)
                print("解析结果：\(model.menus.count)")
                var targets = IUMenuModel(menus: [])
//                var newmenu:IUMenu!
//                model.menus.forEach { menu in
//                    let funcName = menu.funcName
//                    //判断是否存在
//                    let has_func = targets.menus.contains(where: { $0.funcName == funcName })
//                    if !has_func {
//                        newmenu = IUMenu(funcName: menu.funcName, ComponentName: menu.ComponentName, funcCode: menu.funcCode)
//                        targets.menus.append(newmenu)
//                    }
////                    print("菜单名：\(String(describing: menu.menuName!))")
//                    newmenu.menuNames!.append(menu.menuName!)
//                }
                
                for menu in model.menus {
                    let firstName = menu.funcName
                    let has_func = targets.menus.contains(where: { $0.funcName == firstName })
                    if has_func{
                        continue
                    }
                    //数组
                    var firstArr:[IUMenu] = []
                    for meunn in model.menus {
                        if meunn.funcName == firstName {
                            firstArr.append(meunn)
                        }
                    }

                    if firstArr.count > 0 {
                        var newmenu:IUMenu!
                        let firstmenu = firstArr[0]
                        var menuName:[String] = []
                        newmenu = IUMenu(funcName: firstmenu.funcName, ComponentName: firstmenu.ComponentName, funcCode: firstmenu.funcCode)
                        firstArr.forEach { menu1 in
                            menuName.append(menu1.menuName!)
                        }
                        newmenu.menuNames = menuName
                        targets.menus.append(newmenu)
                    }
                }
                print(targets)
                //转JSON
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .prettyPrinted
                let menuJson = try! jsonEncoder.encode(targets)
                //写入新文件
                let newfile = JHSources()+"iu.json"
                try! newfile.write(menuJson)
            }
            
            it("读取组件plist") {
                // 静态库数组
                let libPath = JHSources()+"lib.txt"
                let libs = try! libPath.read().split(separator: "\n")
                
                // iu平台菜单清单，补齐静态库
                let jsonPath = JHSources()+"iu-menu.json"
                let jsonData = try! jsonPath.read()
                
                // JSON解析
                let jsonDecoder = JSONDecoder()
                let model = try! jsonDecoder.decode(IUMenuModel.self, from: jsonData)
                print("解析结果：\(model.menus.count)")
                
                let plist = JHSources()+"ComponentsRelation.plist"
                let dicInfo:NSDictionary = NSDictionary(contentsOfFile: plist.string)!
                let funcDic:[String:NSDictionary] = dicInfo["Component Infomation"] as! [String : NSDictionary]
                
                for lib in libs {
                    for key:String in funcDic.keys {
                        let zuj:NSDictionary = funcDic[key]!
                        let libName:String = zuj["libName"]! as! String
                        //拿到.a名称，功能code ->
//                        print("功能code:\(key)库名称：\(libName)")
                        if lib == libName {
                            for menu in model.menus {
                                if menu.funcCode == key {
                                    print("静态库：\(lib):\(String(describing: menu.menuName))")
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
}

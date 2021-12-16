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
            it("解析iu平台的菜单清单json文件") {
                let jsonPath = JHSources()+"iu-menu.json"
                let jsonData = try! jsonPath.read()
                let jsonDecoder = JSONDecoder()
                let model = try! jsonDecoder.decode(IUMenuModel.self, from: jsonData)
                print("解析结果：\(model.iuMenus.count)")
                model.iuMenus.forEach { menu in
                    if menu.menuName.contains("巡查") {
                        print("\(menu.menuName)")
                    }
                }
            }
        }
        
    }
}

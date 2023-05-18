//
//  File.swift
//  
//
//  Created by boyer on 2023/5/18.
//

import Foundation
import Quick
import Nimble
@testable import CmdLib

class OrgJOSNSpecs:QuickSpec
{
    override func spec(){
        
        var orgModels:Org2JSONModel!
        var botModels:Prompt!
        beforeSuite {
            let jsonFile = "/Users/boyer/Desktop/prompt.json"
            let url = URL(fileURLWithPath: jsonFile)
            let data = try! Data(contentsOf: url)
            orgModels = try! JSONDecoder().decode(Org2JSONModel.self, from: data)
            
            let botFile = "/Users/boyer/hsg/chatgpt-on-wechat/plugins/role/roles.json"
            let boturl = URL(fileURLWithPath: botFile)
            let botdata = try! Data(contentsOf: boturl)
            botModels = try! JSONDecoder().decode(Prompt.self, from: botdata)
        }
        xdescribe("bot prompt结构") {
            
            it("查看tag数据如何获取") {
                let tags = botModels.tags
                botModels.roles.map { role in
                    var orgTag = ""
                    role.tags.map { key in
                        let tag = botModels.tags.dic[key] ?? ""
                        orgTag = "\(orgTag):\(tag)"
                    }
                    print(orgTag + ":")
                }
            }
            
        }
        describe("加载json文件") {
            
            it("读取JSON数据") {
                print(orgModels.properties.author)
                _ = orgModels.contents.map { first in
                    // 一级 headline ：AI Prompt
                    let properties = first.properties
                    let contents = first.contents
                    let remark = first.drawer
                    let node = properties.rawValue
                    let tags = properties.tags
                    _ = contents.map { second in
                        let secondProperty = second.properties
                        let secondContents = second.contents
                        let titlename = secondProperty.rawValue
                        //二级 headline: prompt / 模板
                        if titlename == "Prompt"{
                            //获取 prompt
                            _ = secondContents.map { third in
                                // 三级段落：
                                if third.properties.type == "paragraph"
                                {
                                    _ = third.contents.map { four in
                                        //获取段落：contents 数组
                                        print(four.contents)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
}

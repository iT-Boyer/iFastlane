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
            orgModels = Org2JSONModel.parsed(data:data)
            
            let botFile = "/Users/boyer/hsg/chatgpt-on-wechat/plugins/role/roles.json"
            let boturl = URL(fileURLWithPath: botFile)
            let botdata = try! Data(contentsOf: boturl)
            botModels = try! JSONDecoder().decode(Prompt.self, from: botdata)
        }
        xdescribe("bot prompt结构") {
            
            it("查看tag数据如何获取") {
//                let tags = botModels.tags
//                botModels.roles.map { role in
//                    var orgTag = ""
//                    role.tags.map { key in
//                        let tag = botModels.tags.dic[key] ?? ""
//                        orgTag = "\(orgTag):\(tag)"
//                    }
//                    print(orgTag + ":")
//                }
            }
            
        }
        describe("加载json文件") {
            
            it("读取JSON数据") {
                print(orgModels.properties.author)
                var prompts = orgModels.contents.compactMap{ first -> Role  in
                    // 一级 headline ：AI Prompt
                    let remark = first.drawer?.remark
                    let title = first.properties.rawValue
                    let tags = first.properties.tags
                    let prompt = Org2JSON.getOrgPrompt(type: "system", firstContent: first)
                    let template = Org2JSON.getOrgPrompt(type: "user", firstContent: first)
                    print(template + "\n" + prompt)
                    
                    let role = Role(title: title ?? "",
                                    description: prompt,
                                    descn: prompt,
                                    wrapper: template,
                                    remark: remark ?? "",
                                    tags: tags ?? [])
                    return role
                }
                let promptJson = Prompt(roles: prompts)
                
            }
        }
    }
    
    
}

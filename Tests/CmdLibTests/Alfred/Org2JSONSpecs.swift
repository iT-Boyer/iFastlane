//
//  File.swift
//  
//
//  Created by boyer on 2023/5/18.
//

import Foundation
import Quick
import Nimble
import SwiftShell
import PathKit
@testable import CmdLib

class OrgJOSNSpecs:QuickSpec
{
    override func spec(){
        
        var orgModels:Org2JSONModel!
        var botModels:Prompt!
        beforeSuite {
            // 执行 ox-json-export-file
            SwiftShell.run(bash: "/usr/local/bin/emacsclient -s doom --eval '(ox-json-export-prompt)'")
//            let output = try? runAsync("/usr/local/bin/emacsclient","-s","doom", "--eval","(ox-json-export-prompt)").finish().stdout.read()
//            let datass = output!.data(using: .utf8)!
//            orgModels = Org2JSONModel.parsed(data:datass)
            
            let jsonFile = "/Users/boyer/hsg/iNotes/content-org/prompt/prompt.json"
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
        xdescribe("加载json文件") {
            
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
            
        describe("将 org -> json - model -> prompt.json") {
            it("生成 obsidian 中的 TextGenater插件模板") {
                var prompts = orgModels.contents.map{ first in
                    let remark = first.drawer?.remark ?? ""
                    let title = first.properties.rawValue ?? ""
                    let tags = first.properties.tags
                    let prompt = Org2JSON.getOrgPrompt(type: "system", firstContent: first)
                    let template = Org2JSON.getOrgPrompt(type: "user", firstContent: first)
                    print(template + "\n" + prompt)
                    // obsidian text generator
                    
                    let obsidianfile = "hsg/iHabit/textgenerator/prompts/roles/\(title).md"
                    let obsidiansnippet = Path.home+obsidianfile
                    print("生成文件: \(obsidiansnippet)")
                    let obsnippet = """
                          ---
                          PromptInfo:
                            promptId: \(UUID().uuidString)
                            name: \(title)
                            description: \(remark)
                            required_values:
                            author: it-boyer
                            tags:
                            version: 0.0.1
                          config:
                            mode: insert
                            system: \(prompt)
                          ---
                          
                          {{{selection}}}
                          """
                    try! obsidiansnippet.write(obsnippet)
                }
            }
        }
    }
}

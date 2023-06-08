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
            //该单例，主要是验证目的： 解析 ox-json 生成的json 文件，验证结果。
            it("读取JSON数据") {
                print(orgModels.properties.author)
                var prompts = orgModels.contents.compactMap{ first -> Role  in
                    // 一级 headline ：AI Prompt
                    let remark = first.drawer?.remark
                    let alias = first.drawer?.alias
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
        //解析prompt.org 文件，转为兼容 Obsidian 插件的模板
        xdescribe("将 org -> json - model -> prompt.json") {
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
//                    print("生成文件: \(obsidiansnippet)")
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

        //添加新字段，需要修改model 数据结构
        //例如：想在条目的属性中添加别名：alias
        //第一步：在 orgDrawer model 中添加声明
        //第二步：解析 prompt.org 文件，拼接字符串，写入文件中。
        //例如下面单元测试：
        fdescribe("更新org文件批量添加新字段"){
            it("添加别名字段"){
                // 在 org 属性中添加 alias 字段：title 的全拼
                var content = ""
                _ = orgModels.contents.map{item in
                    let remark = item.drawer?.remark ?? ""
                    let alias = item.drawer?.alias ?? ""
                    let orgID = item.drawer?.ID ?? UUID().uuidString
                    let title = item.properties.rawValue ?? ""
                    let tags = item.properties.tags
                    let prompt = Org2JSON.getOrgPrompt(type: "system", firstContent: item)
                    let template = Org2JSON.getOrgPrompt(type: "user", firstContent: item)
                    let priority = item.properties.priority ?? 0
                    //json 转 org-mode ,ox-json only parse #A
                    var priorityvalue = " "
                    if (priority == 65)  {
                        priorityvalue = " [#A] "
                    }

                    if (title == "充当打火机"
                        || title == "语言输入优化"
                        || title == "论文式回答"
                        || title == "诗人"){
                        print("\(title) priority: \(priority)")
                        print("别名：\(alias) ID: \(orgID)")
                    }
                    var orgTag = ""
                    _ = tags!.map { key in
                        //let tag = prompt.tags.dic[key] ?? ""
                        orgTag = "\(orgTag):\(key)"
                    }
                    if !orgTag.isEmpty {
                        orgTag = orgTag+":"
                    }
                    let org_gpt = """
                      *\(priorityvalue)\(title)   \(orgTag)
                      :PROPERTIES:
                      :remark: \(remark)
                      :alias: \(alias)
                      :ID: \(orgID)
                      :END:

                      ** system
                      \(prompt)
                      ** user
                      \(template)
                      
                      """
                    content = content + org_gpt
                }
                let org = "Desktop/prompt.org"
                let orgFile = Path.home+org
                try! orgFile.write(content)
            }
        }
        //制作 rime 词典，先了解词典的格式，是简单的yaml 格式。
        //实现：解析 prompt.org 文件，按照 rime 词典格式拼接字符串，写入目标文件。
        xdescribe("制作 rime 词库脚本迁移") {
            it("拼接字符串，存入到rime的词典文件"){
                var dicStr = """
                  ---
                  name: chatgpt-prompts promot.scels
                  version: "1.0"
                  sort: by_weight
                  use_preset_vocabulary: true
                  # 此处为扩充词库（基本）默认链接载入的词库
                  # import_tables:
                  # - luna_pinyin
                  # - luna_pinyin.sogou
                  ...
                  
                  """
                
                _ = orgModels.contents.map{item in
                    let title = item.properties.rawValue ?? ""
                    let alias = item.drawer?.alias ?? ""
                    let prompt = Org2JSON.getOrgPrompt(type: "system", firstContent: item)
                    let tmp = "\(prompt)\t\(alias)\t1\n"
                    dicStr = dicStr + "\n" + tmp
                }
                print("--------")
                let rime_dicfile = "hsg/rime-trime/chatgpt-prompts.dict.yaml"
                let rime_dic = Path.home+rime_dicfile
                try! rime_dic.write(dicStr)
            }
        }
    }
}
// 在swift 代码中如何表示tab制表符 解释一下	符号
// 在 Swift 代码中可以使用 =\t= 来表示 tab 制表符。
// 在 swift 使用 PathKit 库判断文件是否存在，否则，新建一个空文件


//
//  File.swift
//  
//
//  Created by boyer on 2023/5/18.
//

import Foundation
// 用法：./af org2json -f ~/hsg/iNotes/content-org/prompt/prompt.json
// 需要先使用 ox-json 把 prompt.org 文件转为 json 文件
public struct Org2JSON {
    
    public static func toPrompt(json:String) -> String? {
        // 使用 JSONEncoder 解析本地的json 文件，转为model 对象。
        let url = URL(fileURLWithPath: json)
        let data = try! Data(contentsOf: url)
//        let orgModels = Org2JSONModel.parsed(data:data)
        let orgModels = try! JSONDecoder().decode(Org2JSONModel.self, from: data)
        var prompts = orgModels.contents.compactMap{ first -> Role  in
            // 一级 headline ：AI Prompt
            let remark = first.drawer?.remark
            let title = first.properties.rawValue
            let tags = first.properties.tags
            let prompt = getOrgPrompt(type: "system", firstContent: first)
            let template = getOrgPrompt(type: "user", firstContent: first)
//            print(template + "\n" + prompt)
            
            let role = Role(title: title ?? "",
                            description: prompt,
                            descn: prompt,
                            wrapper: template,
                            remark: remark ?? "",
                            tags: tags ?? [])
            return role
        }
        let promptModel = Prompt(roles: prompts)
        let newfile = "/Users/boyer/hsg/iNotes/content/prompt/roles.json"
        CmdTools.writeToFile(data: promptModel,to:newfile)
        return ""
    }
    
    static func getOrgPrompt(type:String, firstContent:FirstContent) -> String {
        var result = ""
        _ =  firstContent.contents.map { second in
            let titlename = second.properties.rawValue
            //二级 headline: prompt / 模板
            if titlename == type {
                //获取 prompt
                _ = second.contents.map { section in
                    // 三级章节：
                    if section.type == "section"
                    {
                        _ = section.contents.map { paragraph in
                            //四级段落：contents 数组
                            if paragraph.type == "paragraph"
                            {
                                _ = paragraph.contents.map { five in
                                    result = result + "\n" + five
//                                    print(result)
                                }
                            }
                        }
                    }
                }
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


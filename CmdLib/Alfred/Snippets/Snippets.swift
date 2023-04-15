//
//  Snippets.swift
//  CmdLib
//
//  Created by boyer on 2022/7/19.
//

import Foundation
import PathKit

struct AlfredSnippet:Codable {
    
    var AlfredSnippet:SnippetModel?
    
    public func toJson()->String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        guard let resultData = try? jsonEncoder.encode(self) else { return nil}
        let resultJson = String(data: resultData, encoding: .utf8) ?? ""
        return resultJson
    }
}

// MARK: - AlfredSnippet
struct AlfredModel: Codable {
    let alfredsnippet: SnippetModel
}

// MARK: - SnippetModel
struct SnippetModel: Codable {
    var  uid, name, keyword,snippet: String
    var dontautoexpand:Bool?
}


// MARK: - Prompt
struct Prompt: Codable {
    let tags: Tags
    let roles: [Role]
}

// MARK: - Role
struct Role: Codable {
    var title, description, descn, wrapper: String
    let remark: String
    let tags: [String]
}

// MARK: - Tags
struct Tags: Codable {
    let favorite, mind, write, article: String
    let text, comments, code, life: String
    let interesting, language, speech, social: String
    let philosophy: String
}


//1. 加载json 文件
//2. 转为model 对象
//3. 导出snippet
//  1. alfred snippet
//  2. emacs snippet
public struct Snippets {
    
    public static func toSnippets(json:String) -> String? {
        // 使用 JSONEncoder 解析本地的json 文件，转为model 对象。
        let url = URL(fileURLWithPath: json)
        let data = try! Data(contentsOf: url)
        let prompt = try! JSONDecoder().decode(Prompt.self, from: data)
        prompt.roles.map { role in
            // 保存为json 文件
            do {
                let jsonEncoder = JSONEncoder()
                let alfred = SnippetModel(uid: UUID().uuidString,
                                          name: role.title,
                                          keyword: role.title.pinyin.lowercased(),
                                          snippet: role.descn)
                let alfredM = AlfredModel(alfredsnippet: alfred)
                jsonEncoder.outputFormatting = .prettyPrinted
                let resultData = try jsonEncoder.encode(alfredM)
                let filename = alfred.name.pinyin.lowercased() + " [\(alfred.uid)]"
                print(alfred.name+filename)
                let newfile = "/Users/boyer/Desktop/propmt/\(filename).json"
                let url = URL(fileURLWithPath: newfile)
                try resultData.write(to: url, options: .atomic)
                
                // 把字符串保存为文件
                var wrapper = role.wrapper
                wrapper.replaceAll(matching: "\n.*$", with: "")
                let snippet = """
                    # -*- mode: snippet -*-
                    # name: \(alfred.name)
                    # key: \(alfred.keyword)
                    # group: \(role.tags.first ?? "")
                    # --
                    #+begin_ai markdown :max-tokens 250
                    [SYS]: \(alfred.snippet)

                    [ME]: \(wrapper)$0
                    #+end_ai
                    """
                let snippetfile = ".doom.d/snippets/org-mode/ai/\(alfred.name)"
                let emacsnippet = Path.home+snippetfile
                try! emacsnippet.write(snippet)
            } catch {
                print("生成失败")
            }
        }
        return "生成成功"
    }

    
    func export(file:String?) {
        //TODO: 写入json文件，文件名格式：snippet [uid].json
        
        //TODO: 生成zip包，重命名snippet.alfredsnippets
        
        //TODO: 安装到Alfred，使用open命令
        
    }
}



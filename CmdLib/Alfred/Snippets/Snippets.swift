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
            var wrapper = role.wrapper
            wrapper.replaceAll(matching: "\n.*$", with: "")
            do {
                // alfred -----
                let jsonEncoder = JSONEncoder()
                let alfred = SnippetModel(uid: UUID().uuidString,
                                          name: role.title,
                                          keyword: role.title.pinyin.lowercased(),
                                          snippet: role.descn)
                let alfredM = AlfredModel(alfredsnippet: alfred)
                jsonEncoder.outputFormatting = .prettyPrinted
                let resultData = try jsonEncoder.encode(alfredM)
                let filename = alfred.name + " [\(alfred.uid)]"
                let newfile = "/Users/boyer/Desktop/propmt/\(filename).json"
                let url = URL(fileURLWithPath: newfile)
                try resultData.write(to: url, options: .atomic)
                
                // emacs-snippet ---把字符串保存为文件 ---
                let snippet = """
                    # -*- mode: snippet -*-
                    # name: \(role.title)
                    # key: \(alfred.keyword)
                    # group: \(role.tags.first ?? "")
                    # --
                    #+begin_ai markdown :max-tokens 250
                    [SYS]: \(role.descn)

                    [ME]: \(wrapper)
                    $0
                    #+end_ai
                    """
                let snippetfile = ".doom.d/snippets/org-mode/ai/\(alfred.name)"
                let emacsnippet = Path.home+snippetfile
                try! emacsnippet.write(snippet)

                // emacs snippets
                let mindfile = ".doom.d/snippets/mind-wave-chat-mode/\(alfred.name)"
                let mindnippet = Path.home+mindfile
                let mindsnippet = """
                    # -*- mode: snippet -*-
                    # name: \(role.title)
                    # key: \(alfred.keyword)
                    # group: \(role.tags.first ?? "")
                    # --
                    \(role.descn)
                    """
                try! mindnippet.write(mindsnippet)

                /*
                ---
                 PromptInfo:
                 promptId: accountantAwesome
                 name: 💰 Accountant
                 description: I want you to act as an accountant and come up with creative ways to manage finances. Youll need to consider budgeting, investment strategies and risk management when creating a financial plan for your client. In some cases, you may also need to provide advice on taxation laws and regulations in order to help them maximize their profits.
                 required_values:
                 author: awesome-chatgpt-prompts
                 tags:
                 version: 0.0.1
                 config:
                 mode: insert
                 system: I want you to act as an accountant and come up with creative ways to manage finances. Youll need to consider budgeting, investment strategies and risk management when creating a financial plan for your client. In some cases, you may also need to provide advice on taxation laws and regulations in order to help them maximize their profits.
                 ---

                 {{{selection}}}

                 */
                // obsidian text generator
                let obsidianfile = "hsg/iNotes/Obsidian/textgenerator/prompts/roles/\(alfred.name).md"
                let obsidiansnippet = Path.home+obsidianfile
                print("生成文件: \(obsidiansnippet)")
                let obsnippet = """
                  ---
                  PromptInfo:
                    promptId: \(alfred.uid)
                    name: \(alfred.name)
                    description: \(role.remark)
                    required_values:
                    author: it-boyer
                    tags:
                    version: 0.0.1
                  config:
                    mode: insert
                    system: \(alfred.snippet)
                  ---

                  {{{selection}}}
                  """
                try! obsidiansnippet.write(obsnippet)

                //auto-gpt -----
                //使用方法：python -m auto-gpt --settings-file role.yaml
                let auto_gpt = """
                    ai_name: \(role.title)
                    ai_role: \(role.descn)
                    ai_goals:
                    - \(role.remark)
                    - api_budget: 0.2
                    """
                let autofile = ".dotfiles/auto-gpt/roles/\(role.title).yaml"
                let autogpt = Path.home+autofile
                try! autogpt.write(auto_gpt)
                
                //生成chatfred 的aliases
                //使用方法：把chatfred的内容拷贝到chatfred 配置项中。
                let alfred_aliases = role.title.pinyin.lowercased() + "=" + role.descn + ";\n"
                let fred = "Desktop/chatfred.txt"
                let chatfred = Path.home+fred
//                try! chatfred.append(alfred_aliases)
                let fileHandle = try FileHandle(forWritingTo: chatfred.url)
                    fileHandle.seekToEndOfFile()
                    if let data = alfred_aliases.data(using: .utf8) {
                        fileHandle.write(data)
                    }
                    fileHandle.closeFile()
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

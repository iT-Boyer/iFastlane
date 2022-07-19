//
//  Snippets.swift
//  CmdLib
//
//  Created by boyer on 2022/7/19.
//

import Foundation

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

struct SnippetModel:Codable {
    var uid,name,keyword,snippet:String?
    var dontautoexpand:Bool?
}

public struct Snippets {
    
    public static func save(name:String?, key:String?, snippet:String?) -> String? {
        let model = SnippetModel(uid: "",name: name, keyword: key, snippet: snippet,dontautoexpand: true)
        let alfredSnippet = AlfredSnippet(AlfredSnippet: model)
        return alfredSnippet.toJson()
    }
    
    func export(file:String?) {
        //TODO: 写入json文件，文件名格式：snippet [uid].json
        
        //TODO: 生成zip包，重命名snippet.alfredsnippets
        
        //TODO: 安装到Alfred，使用open命令
    }
}

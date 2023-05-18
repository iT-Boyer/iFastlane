//
//  File.swift
//  
//
//  Created by boyer on 2023/5/18.
//

import Foundation

public struct Org2JSON {
    
    public static func toPrompt(json:String) -> String? {
        // 使用 JSONEncoder 解析本地的json 文件，转为model 对象。
        let url = URL(fileURLWithPath: json)
        let data = try! Data(contentsOf: url)
        let org = try! JSONDecoder().decode(Org2JSONModel.self, from: data)
        
        return ""
    }
}

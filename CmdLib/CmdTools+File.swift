//
//  File.swift
//  
//
//  Created by boyer on 2023/5/18.
//

import Foundation

extension CmdTools{
    ///把数据存储为json文件
    public static func writeToFile(data:Codable, to:String) {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let resultData = try jsonEncoder.encode(data)
            let newfile = to 
            let fileurl = URL(fileURLWithPath: newfile)
            try resultData.write(to: fileurl, options: .atomic)
        } catch{
            fatalError(#function+"存储失败：\(error)")
        }
    }
}

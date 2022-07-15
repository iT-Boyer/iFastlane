//
//  ResultModel.swift
//  AEXML
//
//  Created by boyer on 2022/7/15.
//

import Foundation
import SwiftShell

struct AlfredJSON:Codable {
    var items:[ResultModel]?
    // 归档
    func toArchive(file:String) {
        do{
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let resultData = try jsonEncoder.encode(self)
            let newfile = "/Users/boyer/Desktop/\(file)"
            let url = URL(fileURLWithPath: newfile)
            try resultData.write(to: url, options: .atomic)
        }catch{
            print("归档失败...\(error.localizedDescription)")
            return nil
        }
    }
    
    func toJson()->String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        guard let resultData = try? jsonEncoder.encode(self) else { return nil}
        let resultJson = String(data: resultData, encoding: .utf8) ?? ""
        return resultJson
    }
}

// MARK: - Item
struct ResultModel: Codable {
    var uid, type, title: String?
    var subtitle: String?
    var arg, autocomplete: String?
    var icon: Icon?
    var valid: Bool?
    var quicklookurl: String?
    var mods: Mods?
    var text: Text?
}

// MARK: - Icon
struct Icon: Codable {
    var type, path: String?
}

// MARK: - Mods
struct Mods: Codable {
    var alt, cmd: Alt?
}

// MARK: - Alt
struct Alt: Codable {
    var valid: Bool?
    var arg: String?
    var subtitle: String?
}

// MARK: - Text
struct Text: Codable {
    var copy, largetype: String?
}

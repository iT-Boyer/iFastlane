//
//  RGB2Hex.swift
//  AEXML
//
//  Created by boyer on 2022/7/20.
//

import AppKit

public struct RGB2HexAPI {
    
    public static func to(red:CGFloat, green:CGFloat, blue:CGFloat)->String? {
        let rgbColor = NSColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
        guard let hex = rgbColor.hexString else {return nil}
        let startIndex = hex.index(hex.startIndex, offsetBy: 1)
        let arg = String(hex[startIndex..<hex.endIndex])
        let item = ResultModel(title:hex,arg: arg)
        return AlfredJSON(items: [item]).toJson()
    }
}

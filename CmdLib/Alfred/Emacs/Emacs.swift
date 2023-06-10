//
//  File.swift
//  
//
//  Created by boyer on 2023/5/18.
//

import Foundation
import SwiftShell
import XMLCoder
import Regex
import PathKit

struct RSSModel: Codable {
    struct ItemModel: Codable, Equatable {
        let title: String
        var link: String
        let pubDate:String
        let author:String
        let guid:String
        let description: String
        }
    struct ChannelModel: Codable, Equatable {
        let title: String
        let link: String
        let description: String
        let generator: String
        let language: String
        let managingEditor: String
        let webMaster: String
        let lastBuildDate: String
        let item:[ItemModel]
        }
    let channel: ChannelModel
    
}

// 用法：./af Emacs -f ~/hsg/iNotes/content-org/prompt/prompt.json
// 需要先使用 ox-json 把 prompt.org 文件转为 json 文件
public struct Emacs {
    
    public static func build(readme:String = "~/hsg/iT-Boyer/README.md" ,
                             rss:String = "http://localhost:1313/index.xml") -> String? {
        // 使用 JSONEncoder 解析本地的json 文件，转为model 对象。
        guard let url = URL(string: rss) else {
            print("Invalid URL")
            return ""
        }
        do {
            let xml = try String(contentsOf: url)
            let rss = try! XMLDecoder().decode(RSSModel.self, from: Data(xml.utf8))
            // replace readme blog
            var blog  = ""
            for item in rss.channel.item{
                let link = item.link.replacingFirst(matching: "localhost:1313", with: "it-boyer.github.io")
//                blog = blog + "<a herf=\(link)>\(item.title)</a>\n"
                blog = blog + "[\(item.title)](\(link))   \n"
            }
            //print(blog)
            //regex
            let readmePath = Path(readme)
            let readme:String = try! readmePath.read()
            let regex = Regex("<!-- blog starts -->[^`]*?<!-- blog ends -->")
            let links = "<!-- blog starts -->\n\(blog)\n<!-- blog ends -->"
            let result = readme.replacingFirst(matching: regex, with: links)
            //print(result)
            try readmePath.write(result)
        } catch {
            print("Error retrieving XML: \(error)")
        }
        return ""
    }
}


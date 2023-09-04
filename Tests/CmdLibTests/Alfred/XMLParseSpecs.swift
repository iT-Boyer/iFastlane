
import Foundation
import Quick
import Nimble
import SwiftShell
import PathKit
import XMLCoder
import Regex
@testable import CmdLib


class XMLParseSpecs:QuickSpec{
    override class func spec(){
        fdescribe("获取xml 数据") {

            it("xml 数据") {
                guard let url = URL(string: "http://localhost:1313/index.xml") else {
                    print("Invalid URL")
                    return
                }
                do {
                    let xml = try String(contentsOf: url)
                    let rss = try! XMLDecoder().decode(RSSModel.self, from: Data(xml.utf8))
                    // replace readme blog
                    var blog  = ""
                    for item in rss.channel.item{
                        blog = blog + "<a herf=\(item.link)>\(item.title)</a>\n"
                    }
                    //print(blog)
                    //regex
                    let readmePath:Path = Resources()+"README.md"
                    let readme:String = try! readmePath.read()
                    let regex = Regex("<!-- blog starts -->[^`]*?<!-- blog ends -->")
                    let links = "<!-- blog starts -->\n\(blog)\n<!-- blog ends -->"
                    let result = readme.replacingFirst(matching: regex, with: links)
                    print(result)
                    try readmePath.write(result)
                } catch {
                    print("Error retrieving XML: \(error)")
                }
            }
        }
    }
}



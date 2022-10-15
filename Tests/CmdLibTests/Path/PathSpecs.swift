//
//  File.swift
//  
//
//  Created by boyer on 2022/10/15.
//

import Foundation
import Quick
import PathKit

class PathSpecs: QuickSpec {
    override func spec() {
        describe("拷贝文件") {
            
            it("拷贝chrome到临时目录") {
                let chrome = Path("/Users/boyer/Library/Application Support/Google/Chrome/Default/History")
                let tmp = Path("/Users/boyer/tmp/History")
                do {
                    if (tmp.exists) {try tmp.delete()}
                    try chrome.copy(tmp)
                } catch {
                    print("错误信息：\(error)")
                }
            }
        }
    }
}

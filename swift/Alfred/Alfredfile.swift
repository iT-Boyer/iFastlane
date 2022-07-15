//
//  Alfred.swift
//  Runner
//
//  Created by boyer on 2022/7/14.
//

import Foundation
import Fastlane
import SwiftShell

class Alfredfile: LaneFile
{
    func beforeAll(with lane: String) {
        
    }
    /// 编译静态库，实现指定生成路径
    /// - Parameters:
    ///   - file: file归档文件路径
    ///  runner lane hot file tt.json > /dev/null 2>&1 && cat ~/Desktop/tt.json
    func hotLane(withOptions options: [String : String]?) {
        if let path = options?["file"]
        {
            var wf = AlfredJSON(items: [])
            for i in 0..<4
            {
                let item = ResultModel(uid: "\(i)", type: "test", title: "title\(i)")
                wf.items?.append(item)
            }
            wf.toArchive(file: path)
//            print(wf.ToJSON())
        }
    }
}

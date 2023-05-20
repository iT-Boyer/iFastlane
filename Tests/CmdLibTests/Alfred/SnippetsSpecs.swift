//
//  File.swift
//  
//
//  Created by boyer on 2023/5/20.
//

import Foundation
import Quick
import Nimble
@testable import CmdLib
import PathKit

class SnippetsSpecs:QuickSpec
{
    override func spec(){
        
        var promotdict:[Dictionary<String,String>]!
        beforeSuite {
            let jsonFile = "/Users/boyer/Desktop/prompts-zh.json"
            let url = URL(fileURLWithPath: jsonFile)
            if let data = try? Data(contentsOf: url) {
//                let str = String(data: data, encoding: .utf8)
//                print(str)
                if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String,String>] {
                    promotdict = dict
                }
            }
        }
        describe("bot prompt结构") {
            
            it("查看tag数据如何获取") {
                let org = "Desktop/prompt.org"
                let orgPrompt = Path.home+org
                if let orgfileHandle = try? FileHandle(forWritingTo: orgPrompt.url){
                    
                    _ = promotdict.map { prompt in
                        let role = prompt["act"] ?? ""
                        let system = prompt["prompt"] ?? ""
                        let result = """
                            * \(role)
                            :PROPERTIES:
                            :remark: \(role)
                            :END:

                            ** system
                            \(system)
                            ** user
                            
                            """
                        orgfileHandle.seekToEndOfFile()
                            if let data = result.data(using: .utf8) {
                                orgfileHandle.write(data)
                            }
                    }
                    orgfileHandle.closeFile()
                }
                
                
                
            }
        }
    }
}

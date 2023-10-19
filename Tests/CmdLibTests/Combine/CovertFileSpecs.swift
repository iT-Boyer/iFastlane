//
//  File.swift
//  
//
//  Created by boyer on 2023/9/6.
//

import Combine
import Quick
import Nimble

class CovertFileSpecs: QuickSpec {
    
    override class func spec() {
        
        describe("基本练习") {
            
            it("Just发布者的用法") {
                // Just 发布者
                let test = Just(1).map { value -> String in
                    return "Just发布者"
                }.sink { value in
                    print("结果：\(value)")
                }
                // 订阅者
                test.cancel()
            }
        }
    }
}

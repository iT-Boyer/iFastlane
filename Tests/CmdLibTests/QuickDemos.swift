//
//  Tools.swift
//  Runner
//
//  Created by boyer on 2021/12/3.
//  
//

import Quick
import Nimble
@testable import CmdLib

class QuickDemo: QuickSpec {
    override func spec() {
        describe("案例") {
            beforeEach({
                //方法1:访问控制器的View，来触发控制器的.viewDidLoad()
                print("----first-----")
//                let arr = CmdTools.init().arrDiff(arr1: ["1","2","3"], arr2: ["3","4","5"])
//                print(arr)
                
            })
            it("期望值判断") {
                print("222")
                expect(1 + 1).to(equal(10))
            }
            afterEach {
                print("----end-----")
            }
        }
    }
}


//
//  ToolsTests.swift
//  RunnerTests
//
//  Created by boyer on 2021/12/3.
//

import Quick
import Nimble
@testable import CmdLib

//https://github.com/Quick/Quick/blob/main/Documentation/zh-cn/NimbleAssertions.md
class CmdToolsTests: QuickSpec {
    override func spec() {
        it("求差集") {
            //
            let arr1 = ["1","2","3"]
            let arr2 = ["3","4","5"]
            let arr = CmdTools().arrDiff(arr1: arr1, arr2: arr2)
            let exparr = ["2", "1", "5", "4"]
            print("预期结果：\(exparr)")
            expect(arr).toNot(contain("4"))
            
            //案例
            expect(1 + 1).to(equal(4))
            expect(1.2).to(beCloseTo(1.1, within: 0.1))
            expect(3) > 2
            expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
        }
    }
}

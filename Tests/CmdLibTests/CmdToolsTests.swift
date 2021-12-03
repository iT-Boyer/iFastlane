//
//  ToolsTests.swift
//  RunnerTests
//
//  Created by boyer on 2021/12/3.
//

import Quick
import Nimble
@testable import CmdLib

class CmdToolsTests: QuickSpec {
    override func spec() {
        it("求差集") {
            //
            print(CmdTools().arrDiff(arr1: ["1","2","3"], arr2: ["3","4","5"]))
//            expect(Tools().arrDiff(arr1: ["1","2","3"], arr2: ["3","4","5"]))
        }
    }
}

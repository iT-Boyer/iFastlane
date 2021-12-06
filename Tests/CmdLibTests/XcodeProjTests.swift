//
//  XcodeProjTests.swift
//  Runner
//
//  Created by boyer on 2021/12/6.
//  
//

import Quick
import Nimble
@testable import CmdLib
import XCTest
class XcodeProjTests: QuickSpec {
    override func spec() {
        describe("foo") {
        it("获取项目中的相关文件") {
            let cmd = CmdTools()
            cmd.loadProj(proj: "")
        }
        }
    }
}

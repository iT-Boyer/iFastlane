//
//  EnvTests.swift
//  Runner
//
//  Created by boyer on 2021/12/10.
//  
//

import Quick
import Nimble
@testable import CmdLib


class EnvTests: QuickSpec {
    override func spec() {
        describe("验证环境变量") {
            it("根目录") {
                print(root())
            }
            it("资源目录") {
                print(Resources())
            }
            
            it("金和资源目录") {
                print(JHSources())
            }
        }
    }
}

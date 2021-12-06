//
//  FastlaneTests.swift
//  CmdLibTests
//
//  Created by boyer on 2021/12/6.
//

import Quick
import Nimble
import SwiftShell
@testable import CmdLib

class FastlaneTests: QuickSpec {
 
    override func spec() {
        it("编译静态库到桌面目录") {
            let runner = "/Users/boyer/hsg/iFastlane/Runner"
            let output = try! runAsync(runner, "lane", "buildLib").finish().stdout.read()
            print(output)
        }
    }
}

//
//  iBoyer.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane

extension Fastfile {
//class Boyer: LaneFile {
//
//    //:MARK
//    func beforeAll() {
//        print("准备工作完成")
//    }
//
//    func afterAll(currentLane: String) {
//        print("执行完成")
//    }
//
//    func onError(currentLane: String, errorInfo: String) {
//        print("执行错误")
//    }
    
    func downFilelane() {
        desc("从iTunes connect 下载符号表")
        downloadDsyms(username: "724987481@qq.com", appIdentifier: "com.jinher.yangguangshipin")
    }
    
}

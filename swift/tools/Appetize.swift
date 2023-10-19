//
//  File.swift
//  
//
//  Created by boyer on 2022/10/16.
//

import Foundation
import Fastlane
//https://appetize.io
extension Fastfile
{
    
    /** 支持带参数的lane 升级之后 使用空格 来拼接key:value
        调用语法：fastlane [lane] key value key2 value2
        终端调用：fastlane  appetize  path ../path/app.ipa
     https://docs.fastlane.tools/getting-started/ios/fastlane-swift/
     */
    func appetizeLane(withOptions options:[String: String]?) {
        if let path = options?["path"]{
            appetizeLane(path: path)
        }
    }
    
    func appetizeLane(path:String) {
        appetize(apiToken: "tok_wkvivs35obwvkt4pmpyaavj6gu",path: .userDefined(path))
    }
}

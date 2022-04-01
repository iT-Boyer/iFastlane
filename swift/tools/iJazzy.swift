//
//  iJazzy.swift
//  Runner
//
//  Created by boyer on 2021/12/9.
//

import Foundation
import Regex
import Fastlane


extension Fastfile
{
    
    /// 使用jazzy工具生成苹果级别的官方文档
    /// * lane的价值在于集成开发，可以在afterAll之后，生成更新库文档。
    /// - Parameter options: fastlane入参字典
    /// 例子: runner lane doc 库名称
    /// * 目前jazzy配置文件路径为固定，需要通过代码更新来配置文件
    /// * 后续优化，通过入参指定配置文件路径，生成文档
    func docLane(withOptions options:[String: String]?) {
        
        if let value = options?["doc"], value.count > 0
        {
            switch value {
            case Regex("Lib"):
                print("生成CmdLib库文档")
                jazzy(config: "~/hsg/iFastlane/CmdLib/jazzy.yaml", moduleVersion: "1.0.0")
            case Regex("Log"):
                print("生成LogSwift库")
            default:
                jazzy(config: ".osx.jazzy.yaml", moduleVersion: "1.0.0")
            }
        }
    }
    
    
}

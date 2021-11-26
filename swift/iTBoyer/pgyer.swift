//
//  pgyer.swift
//  FastlaneRunner
//
//  Created by jhmac on 2020/7/2.
//  Copyright © 2020 Joshua Liebowitz. All rights reserved.
//

import Foundation
import Fastlane

extension Fastfile
{
    //MARK: 发布到蒲公英平台
    //https://www.pgyer.com/doc/view/fastlane
    
    /// 发布到蒲公英平台
    /// - Parameter api_key: api_key 设置默认值
    /// - Parameter user_key: user_key 设置默认值
    /// - Parameter desc: 每次发布的描述信息
    func uploadPgyer(api_key: String? = "318c51ed714a80fa0beab1abc022965b",
                     user_key: String? = "5d4309fb86e31ab180ae6cbdf42f8e2f",
                     desc: String? = "update by fastlane") {
        pgyer(apiKey: api_key!, userKey: user_key!)
        
//        let command = RubyCommand(commandID: "",
//                                  methodName: "pgyer",
//                                  className: nil,
//                                  args: [ RubyCommand.Argument(name: "api_key", value: api_key),
//                                          RubyCommand.Argument(name: "user_key", value: user_key),
//                                          RubyCommand.Argument(name: "update_description", value: desc)
//            ]
//        )
//        _ = runner.executeCommand(command)
    }
}

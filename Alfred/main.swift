//
//  main.swift
//  Zhot
//
//  Created by jhmac on 2021/4/29.
//

import Foundation

import ArgumentParser // https://gitee.com/iTBoyer/swift-argument-parser
import SwiftyJSON // https://github.com/SwiftyJSON/SwiftyJSON.git

struct Alfred: ParsableCommand {
    // 自定义设置
    static var configuration =
      CommandConfiguration(commandName: "alfred", // 自定义命令名，默认是类型名
                           abstract: "swift工作流",
                           discussion: "使用swift命令实现alfred相关工作流",
                           version: "1.0.0",
                           shouldDisplay: true,
                           subcommands: [Hotop.self],
                           defaultSubcommand: Hotop.self,
                           helpNames: NameSpecification.customLong("h"))
    
}

// 子命令通用入参
struct AlfredOptions: ParsableArguments {

    //MARK: 参数
    @Option(name: [.customShort("l"), .long], help:"列表")
    var list:String
    // @Argument(help: "查看列表")

      //MARK: flag
      // @Flag(name: [.customLong("type"), .customShort("-t")],
            // help: "设置类型：热榜/推荐等")
     // var
}


Alfred.main()

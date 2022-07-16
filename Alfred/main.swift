//
//  main.swift
//  Zhot
//
//  Created by jhmac on 2021/4/29.
//

import Foundation

import ArgumentParser // https://gitee.com/iTBoyer/swift-argument-parser
import CmdLib

struct Alfred: ParsableCommand {
    // 自定义设置
    static var configuration =
      CommandConfiguration(commandName: "alfred", // 自定义命令名，默认是类型名
                           abstract: "swift工作流",
                           discussion: "使用swift命令实现alfred相关工作流",
                           version: "1.0.0",
                           shouldDisplay: true,
                           subcommands: [Hotop.self, Calibre.self],
                           defaultSubcommand: Hotop.self,
                           helpNames: NameSpecification.customLong("h"))
    
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
    
    //MARK: 定义子命令 struct结构体
    struct Hotop:ParsableCommand {
        //MARK: 配置
        static var configuration = CommandConfiguration(abstract:"热榜",
                                                        shouldDisplay: true)
        //加载封装好的指令
        @OptionGroup()
        var customOpts:AlfredOptions
        
        //MARK: flag
        
        //MARK: 校验
        func validate() throws {
            guard customOpts.list.count >= 2 else {
                throw ValidationError("请输入正确的路径")
            }
        }
        
        func run() throws {
            //MARK: 调用workflow脚本
            HotopServer.fetch { result in
                if let json = result.toJson(){
                    print(json)
                }
                Hotop.exit()
            }
        }
    }
    
    struct Calibre: ParsableCommand {
        
        static var configuration = CommandConfiguration(commandName: "calibre",
                                                        abstract: "查询calibre数据库",
                                                        discussion: "通过alfred快速查询calibre图书馆中的图书等信息",
                                                        version: "1",
                                                        shouldDisplay: true,
                                                        subcommands: [],
                                                        defaultSubcommand: nil,
                                                        helpNames: nil)
        
        @Argument
        var title:String = ""
        
        var db:String = "/Users/boyer/Library/Mobile Documents/com~apple~CloudDocs/Emacs/elfeed/db"
        func validate() throws {
            
        }
        
        func run() throws {
            if let json = CalibreDB.filter(title, db: db){
                print(json)
            }
        }
    }
}





Alfred.main()

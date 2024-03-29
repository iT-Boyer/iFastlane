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
                           subcommands: [Hotop.self,
                                         Calibre.self,
                                         RGB2Hex.self,
                                         Safari.self,
                                         SnippetsCmd.self,
                                         Org2JSONCmd.self,
                                         EmacsCmd.self,
                                         AliWebDAV.self,
                                         Music.self,
                                         CmdTask.self],
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
        @Option(name: [.customShort("n"), .long], help:"请输入书名")
        var name:String
        @Option(name:[.customShort("r"), .long], help: "指定calibre根目录")
        var root:String = "/Users/boyer/rclone/Ali/Calibre"
        @Argument
        var title:String = ""
        
        func validate() throws {
            if name.isEmpty{
                throw ValidationError("请输入书名")
            }
        }
        
        func run() throws {
            if let json = CalibreDB.filter(name, db: root){
                print(json)
            }
        }
    }
    
    struct SnippetsCmd:ParsableCommand {
        // 把promot 转为 alfred / emacs snippet
        static var configuration = CommandConfiguration(commandName: "snippet", abstract: "制作Alfred snippets", discussion: "快速创建alfred snippets 批量导入等", version: "1.0", shouldDisplay: true, subcommands: [], defaultSubcommand: nil, helpNames: nil)
        @Option(name: [.customShort("f"),.long], help: "json文件的路径")
        var file:String
        func run() throws {
            //TODO: 生成json文件，并打包为.alfredsnippets包
            if let history = Snippets.toSnippets(json: file){
                print(history)
            }
        }
    }
    
    struct Org2JSONCmd:ParsableCommand {
        // 把promot 转为 alfred / emacs snippet
        static var configuration = CommandConfiguration(commandName: "org2json", abstract: "org转json格式", discussion: "用于管理prompt", version: "1.0", shouldDisplay: true, subcommands: [], defaultSubcommand: nil, helpNames: nil)
        @Option(name: [.customShort("f"),.long], help: "json文件的路径")
        var file:String
        
        @Option(name: [.customShort("t"), .long], help:"输入转换的类型：obs，rime , alfred，bot-json")
        var type:String
       
        func run() throws {
            if(type == "obs"){
                if let history = Org2JSON.toObsidian(org: file){
                    print(history)
                }
            }
            if(type == "rime"){
                if let history = Org2JSON.toRimeDicts(org: file){
                    print(history)
                }
            }
            if(type == "alfred")
            {
                //TODO: 生成json文件，并打包为.alfredsnippets包
                if let history = Org2JSON.toPrompt(json: file){
                    print(history)
                }
            }
        }
    }
    
    struct EmacsCmd:ParsableCommand {
        // 把promot 转为 alfred / emacs snippet
        static var configuration = CommandConfiguration(commandName: "emacs", abstract: "about elisp tools", discussion: "about elisp tools", version: "1.0", shouldDisplay: true, subcommands: [], defaultSubcommand: nil, helpNames: nil)
        @Option(name: [.customShort("f"),.long], help: "readme文件的路径")
        var file:String
       
        func run() throws {
            //TODO: 生成json文件，并打包为.alfredsnippets包
            if let history = Emacs.build(readme: file){
                print(history)
            }
        }
    }
    
    struct RGB2Hex:ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "rgb", abstract: "rgb to hex")
        
        @Option(name: [.customShort("r"), .long], help:"请输入色值：r,g,b")
        var rgb:String
        
        func validate() throws {
            let color = rgb.components(separatedBy: ",")
            if color.count != 3 {
                throw ValidationError("色值错误")
            }
        }
        
        func run() throws {
            let color = rgb.components(separatedBy: ",").compactMap { item -> CGFloat in
                guard let double = Double(item) else { return 0.0 }
                return CGFloat(double)
            }
            if let hex = RGB2HexAPI.to(red: color[0], green: color[1], blue: color[2]){
                print(hex)
            }
        }
    }
    
    struct Safari:ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "sh",abstract: "查询历史记录")
        @Option(name: [.customShort("u"),.long], help: "请输入关键字")
        var keyword:String
        func run() throws {
            if let history = SafariDB.search(keyword){
                print(history)
            }
        }
    }
    
    struct AliWebDAV:ParsableCommand{
        static var configuration = CommandConfiguration(commandName: "ali",abstract: "aliWebDAV转为http")
        @Option(name: [.customShort("d"),.long], help: "请输入dir地址")
        var dir:String
        func run() throws {
            if let history = Ali.to(dir: dir){
                print(history)
            }
        }
    }
    
    // 在命令行多线程阻塞
    // 使用单元测试完成该功能：MusicSpecs--> Ali工具集--> 测试1
    struct Music:ParsableCommand{
        static var configuration = CommandConfiguration(commandName: "music",abstract: "把音乐文件导入music app")
        @Option(name: [.customShort("d"),.long], help: "请输入dir地址")
        var dir:String
        @Option(name: [.customShort("t"),.long], help: "请设置目标目录")
        var to:String = "/Volumes/AIGO/Media.localized/Automatically Add to Music.localized/"
        func run() throws {
            if let history = Ali.wmaTowav(path: dir,to: to){
                print(history)
            }
            Music.exit()
        }
    }
    
    struct CmdTask:ParsableCommand{
        static var configuration = CommandConfiguration(commandName: "Tasks",abstract: "多线程执行指定的命令")
        @Option(name: [.customShort("c"),.long], help: "要多线程执行的命令")
        var cmd:String
        func run() throws {
            if let history = CmdTasks.runShell(cmds:[cmd]){
                print(history)
            }
            CmdTask.exit()
        }
    }
}

Alfred.main()

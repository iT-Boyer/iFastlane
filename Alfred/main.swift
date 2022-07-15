//
//  main.swift
//  Zhot
//
//  Created by jhmac on 2021/4/29.
//

import Foundation

import ArgumentParser // https://gitee.com/iTBoyer/swift-argument-parser
import SwiftyJSON // https://github.com/SwiftyJSON/SwiftyJSON.git
import PythonKit // https://github.com/pvieito/PythonKit.git

struct Alfred: ParsableCommand {
    // 自定义设置
    static var configuration =
      CommandConfiguration(commandName: "alfred", // 自定义命令名，默认是类型名
                           abstract: "swift工作流",
                           discussion: "使用swift命令实现alfred相关工作流",
                           version: "1.0.0",
                           shouldDisplay: true,
                           subcommands: [hotTop.self],
                           defaultSubcommand: hotTop.self,
                           helpNames: NameSpecification.customLong("h"))
}

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

extension Alfred {

    struct Note: Codable {
        var to: String
        var from: String
        var heading: String
        var body: String
    }

    //MARK: 定义子命令 struct结构体
    struct hotTop:ParsableCommand {
        //MARK: 配置
        static var configuration = CommandConfiguration(abstract:"热榜",
                                                        shouldDisplay: true)
        //加载封装好的指令
         @OptionGroup()
         var customOpts:AlfredOptions

        //MARK: flag
        
        //MARK: 校验
        func validate() throws {
            guard projfile.count >= 1 else {
                throw ValidationError("请输入正确的路径")
            }
        }
        
        func run() throws {
            //MARK: 调用workflow脚本
            //使用URLSession同步获取数据（通过添加信号量）
            //https://www.hangge.com/blog/cache/detail_816.html
            let semaphore = DispatchSemaphore(value: 0)
            URLSession.shared.dataTask(with: URL(string: "https://api.zhihu.com/topstory/hot-list")!) { data, response, error in
                
                if error != nil{
                        print(error!)
                    }else{
                        //解析
                        let json: JSON = try! JSON(data:data!)
                        let posts = json["data"]
                        var wf = AlfredJSON(items: [])
                        wf.items = posts.compactMap { json -> ResultModel? in
                            ResultModel(uid: "\(i)", type: "test", title: "title\(i)")
                        }
                        let result = wf.toJson()
                        print(result)
                        //退出命令
                        Alfred.hotTop.exit()
                }
                semaphore.signal()
            }.resume()
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//            print("数据加载完毕！")
        }
}

Alfred.main()

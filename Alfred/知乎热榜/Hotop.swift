//
//  HotopCmd.swift
//  Alfred
//
//  Created by boyer on 2022/7/15.
//

import Foundation
import ArgumentParser

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
        //使用URLSession同步获取数据（通过添加信号量）
        //https://www.hangge.com/blog/cache/detail_816.html
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: URL(string: "https://api.zhihu.com/topstory/hot-list")!) {data, response, error in
            
            if error != nil{
                print(error!)
            }else{
                //解析
                guard let posts:HotopModel =  HotopModel.parsed(data: data) else { return }
                if let roots = posts.data {
                    var wf = AlfredJSON()
                    wf.items = roots.compactMap { root -> ResultModel? in
                        if let target = root.target {
                            guard let tid = target.id else { return nil }
                            let targetid = String(tid)
                            let quicklook = "https://www.zhihu.com/question/" + targetid
                            return ResultModel(uid: targetid,
                                               type: "question",
                                               title:target.title,
                                               subtitle: target.excerpt,
                                               arg: target.url,
                                               quicklookurl: quicklook
                                               )
                        }
                        return nil
                    }
                    if let result = wf.toJson(){
                        print(result)
                    }
                    //退出命令
//                    Alfred.exit()
                }
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
}

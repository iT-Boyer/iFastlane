//
//  HotopServer.swift
//  Alfred
//
//  Created by boyer on 2022/7/16.
//

import Foundation

public struct HotopServer {
    
    public static func fetch(handler:@escaping(AlfredJSON)->Void) {
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
                    let items = roots.compactMap { root -> ResultModel? in
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
                    handler(AlfredJSON(items: items))
                }
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
}

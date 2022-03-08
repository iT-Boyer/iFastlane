//
//  ZTApi.swift
//  CmdLib
//
//  Created by boyer on 2022/3/7.
//

import Foundation
import Alamofire
import SwiftyJSON

class ZTApi {
    static let server = "http://localhost:8084/api.php/v1/"
//    let server = "http://10.147.19.89:8084/api.php/v1/"
    // 登录禅道，获取token
    static func login(account:String, pwd:String) -> String {
        var token = ""
        let url = server + "/api.php/v1/tokens"
        let param = ["account":"hsg","password":"jiwang3203"]
        let semaphore = DispatchSemaphore(value: 0)
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default)
            .response { data in
            let json = JSON(data)
            token = json["token"].stringValue
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return token
    }
    
    // 指定迭代id，返回bug
    static func bugs(of:Int,token:String) -> [ZTBugM]? {
        var bugs:[ZTBugM]!
        let apiUrl = server + "products/1/bugs"
        let semaphore = DispatchSemaphore(value: 0)
        AF.request(apiUrl, method: .get, headers: ["token":token])
            .response { resp in
                let json = JSON(resp.data!)
                let data = try! json["bugs"].rawData()
                bugs = ZTBugM.parsed(data: data)
                bugs.forEach { bug in
                    print(bug.title!)
                }
                semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return bugs
    }
}

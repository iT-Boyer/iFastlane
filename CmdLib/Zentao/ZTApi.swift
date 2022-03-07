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
    
    // 登录禅道，获取token
    static func login(_ server:String,account:String, pwd:String) -> String {
        
        var token = ""
        let url = server + "/api.php/v1/tokens"
        let semaphore = DispatchSemaphore(value: 0)
        AF.request(url, method: .post,
                   parameters: ["account":account,"password":pwd]).response { data in
            let json = JSON(data)
            token = json["token"].stringValue
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return token
    }
}

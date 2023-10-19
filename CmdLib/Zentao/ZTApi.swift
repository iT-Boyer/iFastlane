//
//  ZTApi.swift
//  CmdLib
//
//  Created by boyer on 2022/3/7.
//

import Foundation
import Regex
import Alamofire
import SwiftyJSON

class ZTApi {
    
    //http://127.0.0.1:8084/api.php?m=project&f=bug&id=7&code={{code}}&time={{time}}&token={{token}}
    static let api = "http://localhost:8084/api.php"
    
    //V1 api
    //http://127.0.0.1:8084/api.php/v1/products/1/bugs
    static let apiV1 = "http://localhost:8084/api.php/v1"
    static let account = "admin"
    static let pwd = "jiwang3203"
    
    static let tokenParam: [String:Any] = {
        let code  = "jinher2bug"
        let key   = "ned637noukviu803j1biqm5tfo"
        let timeInterval:TimeInterval = Date().timeIntervalSince1970
        let time = Int(timeInterval)
        let token = "\(code)\(key)\(time)".md5
        return ["code":code, "time":time, "token":token]
    }()
    
//    let server = "http://10.147.19.89:8084/api.php/v1/"
    /// 登录禅道，获取token
    static func login(account:String = account, pwd:String = pwd,handler:@escaping(String)->Void) {
        let url = apiV1 + "/tokens"
        let param = ["account":account,"password":pwd]
//        let semaphore = DispatchSemaphore(value: 0)
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default)
            .response { data in
            let json = JSON(data)
            let token = json["token"].stringValue
            handler(token)
//            semaphore.signal()
        }
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    static func loginV(handler:@escaping(String)->Void) {
        let url = api + "/tokens"
        var params = ["m": "user",
                      "f": "login"] as [String : Any]
        params.merge(tokenParam) { (first, _) in
            first
        }
        let request = URLRequest(url: URL(string: url)!)
        let urlRequest = try! URLEncoding.default.encode(request, with: params)
        AF.request(urlRequest).response { resp in
            if resp.response?.statusCode == 200 {
                guard let data = resp.data else { return }
                let json = JSON(data)
                let token = json["user"]["token"].stringValue
                handler(token)
            }
        }
    }
    
    
    /// 指定迭代id，返回bug
    static func bugs(of product:Int,token:String,handler:@escaping([ZTBugM])->Void) {
        let apiUrl = apiV1 + "/products/\(product)/bugs"
//        let semaphore = DispatchSemaphore(value: 0)
        AF.request(apiUrl, method: .get, headers: ["token":token])
            .response { resp in
                let json = JSON(resp.data!)
                let data = try! json["bugs"].rawData()
                let bugs:[ZTBugM] = ZTBugM.parsed(data: data)
                handler(bugs)
//                semaphore.signal()
        }
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    /// 指定迭代id，返回bug
    static func create(_ bug:ZTAddBugM, of product:Int,token:String,handler:@escaping(ZTBugMV1?)->Void) {
        let apiUrl = apiV1 + "/products/\(product)/bugs"
//        let semaphore = DispatchSemaphore(value: 0)
        let jsonEncoder = JSONEncoder()
//        jsonEncoder.outputFormatting = .prettyPrinted
        let data = try! jsonEncoder.encode(bug)
        var param:[String:Any] = JSON(data).dictionaryObject!
        param["openedBuild"] = ["主干"]
        param["project"] = product
//        print("对象：\(JSON(data).rawString()!)")
        AF.request(apiUrl,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: ["Token":token])
            .response { resp in
                guard let data = resp.data else { return }
                let dataStr = String(data: data, encoding: .utf8)
                print("\(dataStr!)")
                var result = JSON(data)
                if result["error"].exists() {
                    let error = result["error"].stringValue
                    print(error.unicodeScalars)
                    handler(nil)
                }else{
                    let bug:ZTBugMV1 = ZTBugMV1.parsed(data: data)
                    handler(bug)
                }
//                semaphore.signal()
        }
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    /// 直接通过帐号和密码，查看项目
    static func bugs(of:Int,account:String,pwd:String,handler:@escaping([ZTBugM])->Void) {
        login(account: account, pwd: pwd) { token in
            bugs(of: of, token: token) { bugs in
                handler(bugs)
            }
        }
    }
    
    static func imports(_ bugs:[ZTAddBugM],of product:Int, handler:@escaping(ZTBugMV1?)->Void) {
        loginV { tokenn in
            bugs.forEach { add in
                create(add, of: product, token: tokenn) { newbug in
                    handler(newbug)
                }
            }
        }
    }
    
    enum ZTBugType {
        case project,execution,bug
    }
    enum ZTBugAction {
        case view,bug,browse
    }
    //MARK: 免登录接口
    static func bugs(of type:ZTBugType = .project,action:ZTBugAction = .bug,id:Int,handler:@escaping([ZTBugM])->Void) {
        var method = "project"
        var fun = "bug"
        switch type {
        case .project:
            method = "project"
        case .execution:
            method = "execution"
        case .bug:
            method = "bug"
            fun = "browse"
        }
        switch action {
        case .view:
            fun = "view"
        case .bug:
            fun = "bug"
        case .browse:
            fun = "browse"
        }
        var params = ["m": method,
                      "f": fun,
                      "id": id] as [String : Any]
        params.merge(tokenParam) { (first, _) in
            first
        }
        let request = URLRequest(url: URL(string: api)!)
        let urlRequest = try! URLEncoding.default.encode(request, with: params)
        AF.request(urlRequest).response { resp in
            if resp.response?.statusCode == 200 {
                guard let data = resp.data else { return }
//                let dataStr = String(data: data, encoding: .utf8)
//                print("\(dataStr!)")
                let json = JSON(data)
                let bugData = try! json["data"]["bugs"].rawData()
                let bugs:[ZTBugM] = ZTBugM.parsed(data: bugData)
                handler(bugs)
            }
        }
    }
    
    static func JHFilter(bugs:@escaping([ZTAddBugM])->Void) {
        
        JHBugly.parseJson(JHBugly.url, params: JHBugly.parameters) { jhBugs in
            print("jhBugs条数: \(jhBugs.count)")
            ZTApi.bugs(of: .project, action: .bug, id: 7) { ztbugs in
                print("ztbugs条数: \(ztbugs.count)")
                let bms = JHBugly.parseBm(jhBugs)
                // 使用禅道reason内容去重
                let result = bms.compactMap { bm -> ZTAddBugM? in
                    var exist = false
                    for zt in ztbugs {
                        let regex = Regex("(0[xX])?[a-fA-F0-9]+")
                        let zt_title = zt.title!.replacingFirst(matching: regex, with: "")
                        let bm_reason = bm.reason.replacingFirst(matching: regex, with: "")
                        if bm_reason == zt_title {
                            exist = true
                            break
                        }
                    }
                    if !exist{
                        let bug = ZTAddBugM()
                        bug.title = bm.reason
                        bug.steps = bm.detail
                        bug.project = ztbugs[0].project
                        return bug
                    }
                    return nil
                }
                bugs(result)
            }
        }
    }
}

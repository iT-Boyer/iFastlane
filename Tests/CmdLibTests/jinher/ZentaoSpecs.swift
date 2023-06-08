//
//  ZentaoSpecs.swift
//  Runner
//
//  Created by boyer on 2022/3/2.
//  
//
import Foundation
import Quick
import Nimble
import Alamofire
import SwiftyJSON
@testable import CmdLib

//https://www.zentao.net/book/zentaopmshelp/integration-287.html
/**
 m=moduleName&f=methodName& params=params 部分为数据请求参数，根据实际的需求进行设置。
 m:project、
 f:view、
 id:项目ID
 code为应用代号，需要和禅道应用设置中保持一致。
 time位时间戳，可以通过PHP的time函数得到。
 token为数字签名，其算法为：code、密钥、time字符串合并，再进行 md5。
 */
// 禅道API 联调
class ZentaoSpecs: QuickSpec {
    
    override func spec() {
        //禅道服务器
        let url = "http://127.0.0.1:8084/api.php"
        
        xdescribe("免登录获取认证") {
            //免密认证
            var zToken:[String : Any]!
            beforeEach {
                //md5 密钥
                let code  = "jinher2bug"
                let key   = "59871ac7135c224cddcb15bef85cdaf8"
                let timeInterval:TimeInterval = Date().timeIntervalSince1970
                let time = Int(timeInterval)
                let token = "\(code)\(key)\(time)".md5

                zToken = ["code": code,
                          "time": time,
                          "token" :token
                ]
            }
            
            it("查看项目7") {
                var params = ["m": "project",
                              "f": "view",
                              "id": 7] as [String : Any]
                params.merge(zToken) { (first, _) in
                    first
                }
                waitUntil(timeout: .seconds(10)) { done in
                    let request = URLRequest(url: URL(string: url)!)
                    let urlRequest = try! URLEncoding.default.encode(request, with: params)
                    AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            guard let data = resp.data else { return }
                            let dataStr = String(data: data, encoding: .utf8)
                            print("\(dataStr!)")
                        }
                        done()
                    }
                }
            }
            it("查看项目7的bug清单") {
                waitUntil(timeout: .seconds(10)) { done in
                    ZTApi.bugs(of: .project, action: .bug, id: 7) { bugs in
                        print("bugs条数: \(bugs.count)")
                        done()
                    }
                }
            }
            fit("待添加的bug") {
                JHBugly.parameters["rows"] = 1000
                JHBugly.parameters["fromTime"] = "2022-02-28 08:05:05"
                JHBugly.parameters["toTime"] = "2022-03-10 08:05:05"
                waitUntil(timeout: .seconds(5)) { done in
                    ZTApi.JHFilter { bugs in
                        print("bugs条数: \(bugs.count)")
                        done()
                    }
                }
            }
            it("添加bug") {
                //&branch=0&extra=moduleID=0
                var params = ["m": "bug",
                              "f": "create",
                              "productID": 7,
                              "branch": 7,
                              "extra": "moduleID=0"] as [String : Any]
                params.merge(zToken) { (first, _) in
                    first
                }
//                var bug = ZTBugM()
                waitUntil(timeout: .seconds(10)) { done in
                    let request = URLRequest(url: URL(string: url)!)
                    let urlRequest = try! URLEncoding.default.encode(request, with: params)
                    AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            guard let data = resp.data else { return }
                            let dataStr = String(data: data, encoding: .utf8)
                            print("\(dataStr!)")
                        }
                        done()
                    }
                }
            }
        }
        xdescribe("登录方式获取认证") {
            var token = ""
            beforeEach { //获取token凭证
                let params = ["m":"user",
                              "f":"login",
                              "account":"hsg",
                              "password":"jiwang3203"]
                waitUntil(timeout: .seconds(5)) { done in
                    let request = URLRequest(url: URL(string: url)!)
                    let urlRequest = try! URLEncoding.default.encode(request, with: params)
                    AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            guard let data = resp.data else { return }
//                            let dataStr = String(data: data, encoding: .utf8)
//                            print("\(dataStr!)")
                            let json = JSON(data)
                            token = json["user"]["token"].stringValue
                            print(token)
                        }
                        done()
                    }
                }
            }
            fit("通过get访问项目7") {
                let params = ["m": "project",
                              "f": "view",
                              "id": 7] as [String : Any]
                waitUntil(timeout: .seconds(10)) { done in
                    let request = URLRequest(url: URL(string: url)!)
                    var urlRequest = try! URLEncoding.default.encode(request, with: params)
                    urlRequest.headers["token"] = token
                    AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            guard let data = resp.data else { return }
                            let dataStr = String(data: data, encoding: .utf8)
                            print("\(dataStr!)")
                        }
                        done()
                    }
                }
            }
        }
    }
}

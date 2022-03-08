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
        var parameters:[String : Any]!
        var url:String!
        let expect = self.expectation(description: "request should complete")
        beforeEach {
            //md5 密钥
            let code  = "jinher2bug"
            let key   = "59871ac7135c224cddcb15bef85cdaf8"
            let timeInterval:TimeInterval = Date().timeIntervalSince1970
            let time = Int(timeInterval)
            let token = "\(code)\(key)\(time)".md5

            url = "http://127.0.0.1:8084/api.php"
            parameters = ["m": "project",
                          "f": "view",
                          "id": 7,
                          "account":"hsg",
                          "code": code,
                          "time": time,
                          "token" :token
            ]
        }

        xdescribe("demo") {
            //
            xit("token免密码登录接口") {
//                parameters["m"] = "user"
//                parameters["f"] = "apilogin"
                let request = URLRequest(url: URL(string: url)!)
                var urlRequest = try! URLEncoding.default.encode(request, with: parameters)
                AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            guard let data = resp.data else { return }
                            let dataStr = String(data: resp.data!, encoding: .utf8)
                            let json = JSON(data)
                        }
                    expect.fulfill()
                }
                self.waitForExpectations(timeout: 10)
            }

            xit("帐号登录接口") {
                parameters = ["m":"user",
                              "f":"login",
                              "account":"hsg",
                              "password":"jiwang3203"]
                let request = URLRequest(url: URL(string: url)!)
                let urlRequest = try! URLEncoding.default.encode(request, with: parameters)
                AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            guard let data = resp.data else { return }
                            let dataStr = String(data: resp.data!, encoding: .utf8)
                            let json = JSON(data)
                        }
                    expect.fulfill()
                    }
                self.waitForExpectations(timeout: 10)
            }

            it("查看项目") {
                parameters = ["m": "project",
                              "f": "view",
                              "id": 7,
                              "account":"hsg",
                              "password":"jiwang3203"]
                let request = URLRequest(url: URL(string: url)!)
                let urlRequest = try! URLEncoding.default.encode(request, with: parameters)
                AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            guard let data = resp.data else { return }
                            let dataStr = String(data: resp.data!, encoding: .utf8)
                            let json = JSON(data)
                        }
                    expect.fulfill()
                    }
                self.waitForExpectations(timeout: 10)
            }
        }
        
        // 登录获取token
        // 封装bug接口请求，解析bug module
        describe("V1版本api") {
            //登录token
            var token = "l1mhdkdho45sjcdafatmj5o89o"
//            let server = "http://localhost:8084/api.php/v1/"
            let server = "http://10.147.19.89:8084/api.php/v1/"
            let expect = self.expectation(description: "request should complete")
            
            xit("打印token") {
                let apiUrl = server + "tokens"
                let param = ["account":"hsg","password":"jiwang3203"]
                AF.request(apiUrl, method: .post, parameters: param, encoding: JSONEncoding.default)
                    .response { resp in
                        let json = JSON(resp.data!)
                        token = json["token"].stringValue
                        expect.fulfill()
                }
                self.waitForExpectations(timeout: 20)
                print("获取到的token：\(token)")
            }
            
            it("获取bug列表") {
                let apiUrl = server + "products/1/bugs"
                AF.request(apiUrl, method: .get, headers: ["token":token])
                    .response { resp in
                        let json = JSON(resp.data!)
                        let total = json["total"].intValue
                        print("bug条数：\(total)")
                        let bugs:Data = try! json["bugs"].rawData()
                        let array:[ZTBugM] = ZTBugM.parsed(data: bugs)
                        array.forEach { bug in
                            print(bug.title!)
                        }
                        expect.fulfill()
                }
                self.waitForExpectations(timeout: 10)
            }
        }
        
    }
}

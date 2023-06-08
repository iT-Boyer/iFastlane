//
//  ZentaoV1Specs.swift
//  Runner
//
//  Created by boyer on 2022/3/9.
//  
//
import Foundation
import Quick
import Nimble
import Alamofire
import SwiftyJSON
@testable import CmdLib

class myconfig: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        //添加全局闭包
        configuration.beforeEach {
            print("开始-------")
        }
        
        configuration.afterEach {
            print("结束-------")
        }
        
        sharedExamples("共享例子群") {
            it("测试配置使用方法") {
                print("全局支持----")
            }
        }
        sharedExamples("共享例子群----2") {
            it("测试配置使用方法") {
                print("全局支持----2")
            }
        }
        
        
    }
}

class ZentaoV1Specs: QuickSpec {
    override func spec() {
        sharedExamples("获取token") {
            it("局部共享用例") {
                print("局部共享用例++++++")
            }
        }
//        itBehavesLike("everything under the sea")
        beforeSuite {
            print("全局：所有例子之前执行--获取token")
            
        }
        afterSuite {
            print("全局：所有例子结束执行")
        }

        itBehavesLike("共享例子群----2")
        itBehavesLike("共享例子群")
        itBehavesLike("获取token")
        // 登录获取token
        // 封装bug接口请求，解析bug module
        xdescribe("V1版本api") {
            let server = "http://localhost:8084/api.php/v1/"
//            let server = "http://10.147.19.89:8084/api.php/v1/"
            var token = ""
            beforeEach {
                //登录获取token
                waitUntil(timeout: .seconds(2)) { done in
                    let apiUrl = server + "tokens"
                    let param = ["account":"hsg","password":"jiwang3203"]
                    AF.request(apiUrl, method: .post, parameters: param, encoding: JSONEncoding.default)
                        .response { resp in
                            let json = JSON(resp.data!)
                            token = json["token"].stringValue
                            print("获取到的token：\(token)")
                            done()
                    }
                }
            }
            
            it("获取bug列表") {
                let apiUrl = server + "products/1/bugs"
                waitUntil(timeout: .seconds(10)) { done in
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
                            done()
                    }
                }
            }
           
            fit("创建新bug") {
                waitUntil(timeout: .seconds(5)) { done in
                    ZTApi.JHFilter { bugs in
                        ZTApi.imports(bugs, of: 7) { bug in
                            print("已添加：\(bug!.title ?? "")")
                            done()
                        }
                    }
                }
            }
            
        }
    }
}

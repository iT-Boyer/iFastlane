//
//  GitHubTests.swift
//  Runner
//
//  Created by boyer on 2021/12/19.
//  
//
import Foundation
import Quick
import Nimble
import GithubAPI
import XCTest

class GitHubTests: QuickSpec {
    override class func spec() {
        xdescribe("github api 身份认证") {
            var expectation:XCTestExpectation!
            beforeEach {
        //        let semaphore = DispatchSemaphore(value: 0)
                //首先使用 expectationWithDescription 建立一个期望值。
                expectation = XCTestExpectation(description: "token认证")
            }
            
            xit("账号方式登陆") {
                let authentication = BasicAuthentication(username: "username", password: "password")
                UserAPI(authentication: authentication).getUser { (response, error) in
                    if let response = response {
                        print(response)
                    } else {
                        print(error ?? "")
                    }
                }
            }
            
            xit("access token") {
                let authentication = AccessTokenAuthentication(access_token: "2bc44d373067f4c32139506f1d691fa195f05993")
                UserAPI(authentication: authentication).getUser(username: "it-boyer") { (response, error) in
                    if let response = response {
                        print(response)
                    } else {
                        print(error ?? "")
                    }
        //            semaphore.signal()
                    //在异步方法被测试的相关的回调中实现那个期望值
                    expectation.fulfill()
                }
        //        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
                //        在方法底部，增加 waitForExpectationsWithTimeout 方法，指定一个超时，如果测试条件不适合时间范围便会结束执行：
                // self.waitForExpectations(timeout: 20, handler: { error in
                //     //
                //     print("错误信息:\(String(describing: error?.localizedDescription))")
                // })
            }
            
            fit("OAuth2") {
                let authentication = TokenAuthentication(token: "2bc44d373067f4c32139506f1d691fa195f05993")
                UserAPI(authentication: authentication).getAllUsers(since: "1") { (response, error) in
                    if let response = response {
                        print(response)
                    } else {
                        print(error ?? "")
                    }
                    //在异步方法被测试的相关的回调中实现那个期望值
                    expectation.fulfill()
                }

//                self.waitForExpectations(timeout: 20, handler: { error in
//                    //
//                    print("错误信息:\(String(describing: error?.localizedDescription))")
//                })
            }
        }
        
    }
}

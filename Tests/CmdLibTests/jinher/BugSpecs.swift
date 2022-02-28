//
//  BugSpecs.swift
//  Runner
//
//  Created by boyer on 2022/2/28.
//  
//
import Foundation
import Quick
import Nimble
import Alamofire
import SwiftyJSON
import XCTest


/**
 http://oms.iuoooo.com/MError/GetLogList?random=0.7724948616202214&fromTime=2022-02-23%200:01:47&toTime=2022-02-23%2023:59:00&osType=1&runEnvi=3&logState=0&errorType=crash&_search=false&nd=1645667051272&rows=20&page=1&sidx=&sord=asc&appId=
 */
class BugSpecs: QuickSpec {
    override func spec() {
        
        var parameters:[String : Any]!
        var url:String!
        var headers:HTTPHeaders?
        let expect = self.expectation(description: "request should complete")
        beforeEach {
            url = "http://oms.iuoooo.com/MError/GetLogList?random=0.7724948616202214"
            parameters = ["random": 0.9673897022258404,
                          "fromTime":"2022-02-27 08:05:05",
                          "toTime":"2022-02-28 10:05:05",
                          "osType":1,
                          "runEnvi":3,
                          "logState":0,
                          "errorType":"crash",
                          "_search":false,
                          "nd":1646014376681,
                          "rows":20,
                          "page":1,
                          "sidx":"",
                          "sord":"asc",
                          "appId":"", //d8ee9511-8bfb-44e9-8195-e03c173fa2d7
            ]
            headers = ["Content-Type":"application/x-www-form-urlencoded",
                       "Accept":"application/json, text/javascript, */*; q=0.01",
                       "Accept-Encoding":"gzip, deflate"]
        }
        describe("") {
            fit("使用get请求") {
                let request = URLRequest(url: URL(string: url)!)
                var urlRequest = try! URLEncoding.default.encode(request, with: parameters)
                urlRequest.headers["Content-Type"] = "application/json; charset=utf-8"
                urlRequest.headers["Accept"] = "application/json"
                AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                            guard let dataStr = String(data: resp.data!, encoding: String.Encoding(rawValue: enc)) else { return }
                            let datass = dataStr.data(using: .utf8)
                            let json = JSON(datass)
                            let records = json["records"].stringValue
                            print("bug条数: \(records)")
                        }
                    expect.fulfill()
                    }
                self.waitForExpectations(timeout: 20)
            }
            xit("使用post+responseString") {
                AF.request(url,
                           method: .post,
                           parameters: parameters,
                           encoding: URLEncoding.default,
                           headers: headers).responseString{ resp in
                    let dataStr = resp.value!
                    let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                    let datass = dataStr.data(using: String.Encoding(rawValue: enc))
                    let json = JSON(datass)
                    let records = json["records"].stringValue
                    print("bug条数: \(records)")
                    expect.fulfill()
                }
                self.waitForExpectations(timeout: 20)
            }
        }
    }
}

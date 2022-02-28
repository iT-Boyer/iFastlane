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
import Regex
import CSV
import PathKit
@testable import CmdLib


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
        describe("bugly工具问题解析") {
            xit("使用get请求") {
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
                self.waitForExpectations(timeout: 10)
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
            
            xit("正则匹配重要信息") {
                let content = """
                    当前展示的视图控制器:JHTabBarController

                    最后实例化的视图控制器:JHUIWebViewController

                    2.6.0.012920 name:NSGenericException
                    reason:*** Collection <__NSArrayM: 0x28295e1c0> was mutated while being enumerated.
                
                """
                let reg = Regex(":.*\n",options: [.ignoreCase, .anchorsMatchLines])
                let matchingLines = reg.allMatches(in: content)
                var bug = JHBuglyM()
                bug.currVC = matchingLines[0].matchedString
                bug.lastVC = matchingLines[1].matchedString
                bug.name = matchingLines[2].matchedString
                bug.reason = matchingLines[3].matchedString
                bug.version =  Regex("\\d\\.\\d\\.\\d.\\d{1,}").firstMatch(in: content)?.matchedString
                print(bug)
            }
            
            fit("CSV文件解析") {
                let filePath = JHSources().string+"/bug.csv"
                let stream = InputStream(fileAtPath: filePath)!
                // hasHeaderRow must be true.
                let csv = try! CSVReader(stream: stream, hasHeaderRow: true)
                let headerRow = csv.headerRow!
                print("\(headerRow)")
                while let row = csv.next() {
                    print("\(csv["Bug标题"]!)")
                }
            }
            
            xit("读取两天的数据，去重，生成电子表格") {
                JHBugly.parseJson(url, parameters: parameters) { bugArr in
                    //去重
                    let bugs = JHBugly.parseCSV(JHSources() + Path("bug.csv"))
                    bugs.map { bug in
                        print("reason：\(bug.reason)")
                    }
                    
                    let newarr = bugArr.compactMap{ newbug-> JHBuglyM? in
                        //bug name相同的
                        //reason 相同的
                        //控制器相同的
                        var str = newbug.name!
                        guard Regex("").matches(str) else {
                            // 删除行前空格
                            let space = NSCharacterSet.whitespaces
                            str = str.trimmingCharacters(in: space)
                            if str.hasPrefix("//")
                                || str.contains("if ([api_host_adm")
                                || str.contains("update.iuoooo.com")
                            {
                                return nil
                            }
                               return newbug
                        }
                        return nil
                    }
                    //格式化表格打印
                    
                }
            }
        }
    }
}

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
class JHBuglySpecs: QuickSpec {
    override func spec() {
        
        beforeEach {
            JHBugly.parameters["rows"] = 1000
            JHBugly.parameters["fromTime"] = "2022-02-28 08:05:05"
            JHBugly.parameters["toTime"] = "2022-03-10 08:05:05"
        }
        
        xdescribe("金和埋点库api请求") {
            it("使用get请求") {
                waitUntil(timeout: .seconds(5)) { done in
                    let request = URLRequest(url: URL(string: JHBugly.url)!)
                    var urlRequest = try! URLEncoding.default.encode(request, with: JHBugly.parameters)
                    urlRequest.headers["Content-Type"] = "application/json; charset=utf-8"
                    urlRequest.headers["Accept"] = "application/json"
                    AF.request(urlRequest).response { resp in
                        if resp.response?.statusCode == 200 {
                            let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                            guard let dataStr = String(data: resp.data!, encoding: String.Encoding(rawValue: enc)) else { return }
                            let datass = dataStr.data(using: .utf8)
                            let json = JSON(datass!)
                            let records = json["records"].stringValue
                            print("bug条数: \(records)")
                        }
                        done()
                    }
                }
            }
            it("使用post+responseString") {
                waitUntil(timeout: .seconds(5)) { done in
                    let headers:HTTPHeaders? = ["Content-Type":"application/x-www-form-urlencoded",
                                                "Accept":"application/json, text/javascript, */*; q=0.01",
                                                "Accept-Encoding":"gzip, deflate"]
                    AF.request(JHBugly.url,
                               method: .post,
                               parameters: JHBugly.parameters,
                               encoding: URLEncoding.default,
                               headers: headers).responseString{ resp in
                        let dataStr = resp.value!
                        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                        let datass = dataStr.data(using: String.Encoding(rawValue: enc))
                        let json = JSON(datass!)
                        let records = json["records"].stringValue
                        print("bug条数: \(records)")
                        done()
                    }
                }
            }
            
        }
        
        xdescribe("数据转model的解析方法") {
            it("取值转model正则法") {
                let content = """
                    当前展示的视图控制器:JHTabBarController

                    最后实例化的视图控制器:JHUIWebViewController

                    2.6.0.012920 name:NSGenericException
                    reason:*** Collection <__NSArrayM: 0x28295e1c0> was mutated while being enumerated.
                
                    最后实例化的视图控制器:JHUIWebViewController

                    2.6.0.012920 name:NSInvalidArgumentException
                    reason:-[__NSCFString reachabilityChanged:]: unrecognized selector sent to instance 0x2835b0b80
                
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
            
            it("CSV.swift解析法") {
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
        }
        
        describe("分析埋点crash情况") {
            
            fit("统计crash类型和个数") { //JHBugly.crashInfo()
                waitUntil(timeout: .seconds(10)) { done in
                    JHBugly.parseJson(JHBugly.url, params: JHBugly.parameters) { jhBugs in
                        let breason = jhBugs.regexDuplicates({$0.reason})
                        let bname = breason.regexDuplicates({$0.name})
                        print("""
                            分析从\(JHBugly.parameters["fromTime"]!) 到 \(JHBugly.parameters["toTime"]!)
                            本次收集crash总数：\(jhBugs.count) 类型数：\(bname.count) 问题数：\(breason.count)
                            """)
                        let bt = JHBugly.parseBT(breason)
                        bt.forEach { item in
                            print("类型-»:\(item.name ?? "")\n\(item.bugs.count)个bug")
                            let diffReason = item.bugs.regexDuplicates({$0.reason})
                            diffReason.forEach { bm in
                                print("reason-»:\(bm.reason ?? "")")
                            }
                            print("----------")
                        }
                        done()
                    }
                }
            }

            xit("匹配oc方法的正则") {
                let orgStr = "-[UIScrollView removeAllSubViews]: unrecognized selector sent to instance 0x109129c00"
                let result = Regex("\\[.*?\\]").firstMatch(in: orgStr)?.matchedString
                print("匹配结果：\(result)")
            }
        }
    }
}

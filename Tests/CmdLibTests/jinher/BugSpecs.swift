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
                          "fromTime":"2021-01-01 08:05:05",
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
            
            xit("CSV文件解析") {
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
            
            fit("bug正则去重") {
                //
                parameters["rows"] = 1000
                parameters["fromTime"] = "2022-02-28 08:05:05"
                parameters["toTime"] = "2022-03-01 08:05:05"
                JHBugly.parseJson(url, parameters: parameters) { bugArr in
                    //去重
                    let filterModels = bugArr.filterDuplicates({$0.name})
                    let zentaoArr:[JHBuglyM] = JHBugly.parseCSV(JHSources() + Path("bug.csv"))
                    filterModels.map { bug in
                        // name类型去重
                        let arr = bugArr.filter { buga in
                            buga.name == bug.name
                            && !Regex("-\\[.*?\\]").matches(buga.reason!) // 去除含方法-[] 的reason
                        }
                        //金和数据
                        // 使用reason内容 正则去重
                        var arr1 = arr.regexDuplicates({$0.reason})
                        // 使用禅道reason内容去重
                        let arr2 = arr1.compactMap { newbug -> JHBuglyM? in
                            var new:JHBuglyM? = nil
                            for item in zentaoArr {
                                let reasion1 = Regex("(reason:|:)(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").firstMatch(in: newbug.reason!)?.matchedString
                                let reasion2 = Regex("(reason:|:)(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").firstMatch(in: item.reason!)?.matchedString
                                if reasion1 == reasion2 {
                                    new = newbug
                                    break
                                }
                            }
                            return new ?? newbug
                        }
                        
                     
                        print("""
                            \(arr.count)个\(bug.name!)
                            正则去重：true
                            去重总数：\(arr1.count)
                            已录入：\(arr1.count - arr2.count)
                            待录入：\(arr2.count)
                            """)
                        arr2.map { bug in
                            print("待录----:\n\(bug.reason!)")
                        }
                    }
                    expect.fulfill()
                }
                self.waitForExpectations(timeout: 100)
            }
            
            xit("方法去重") {
                parameters["rows"] = 1000
                parameters["fromTime"] = "2022-02-28 08:05:05"
                parameters["toTime"] = "2022-03-01 08:05:05"
                JHBugly.parseJson(url, parameters: parameters) { bugArr in
                    //去重
                    let filterModels = bugArr.filterDuplicates({$0.name})
                    print("""
                        分析从\(parameters["fromTime"]!) 到 \(parameters["toTime"]!)
                        crash总条数：\(bugArr.count)，其中类型数：\(filterModels.count)
                        """)
                    let zentaos = JHBugly.parseCSV(JHSources() + Path("bug.csv"))
                    
                    filterModels.map { bug in
                        // name类型去重
                        let arr = bugArr.filter { buga in
                            buga.name == bug.name
                        }
                        // reason重复
                        var arr1:[JHBuglyM] = []  // 去重resion title
                        var arr2:[JHBuglyM] = [] // 待录入
                        if let funcstr = bug.reason_func {
                            arr1 = arr.filter { buga in
                                buga.reason.contains(funcstr)
                            }
                            arr2 = arr1.filter { bug1 in
                                var add = true
                                zentaos.forEach { ztbug in
                                    if(ztbug.reason.contains(funcstr)){
                                        add = false
                                        return
                                    }
                                }
                                return add
                            }
                            print("""
                                \(arr.count)个\(bug.name!)
                                方法去重：\(bug.reason_func ?? "无")
                                去重总数：\(arr1.count)
                                已录入：\(arr1.count - arr2.count)
                                待录入：\(arr2.count)
                                """)
                            arr1.map { bug in
                                print(bug.reason!)
                            }
                            return
                        }else{
//                            arr1 = arr.filter { buga in
//                                Regex(":(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").matches(buga.reason!)
//                            }
                            arr1 = arr.regexDuplicates({$0.reason})
//                            arr1 = arr1 + arr
//                            arr.forEach { bugr1 in
//
//                                arr1.forEach { addbug in
//                                    let first = Regex(":(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").firstMatch(in: addbug.reason)?.matchedString
//                                    let second = Regex(":(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").firstMatch(in: bugr1.reason)?.matchedString
//                                    if first == second {
////                                        arr1.removeAll(where: { $0 == addbug })
//                                    }
//                                }
//                            }
                            
//                            arr2 = arr1.filter { bug1 in
//                                var add = true
//                                zentaos.forEach { ztbug in
//                                    if(Regex(":(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").matches(ztbug.reason!)){
//                                        add = false
//                                        return
//                                    }
//                                }
//                                return add
//                            }
//                            arr1.forEach { bugr2 in
//
//                                arr2.forEach { addbug in
//                                    let first = Regex(":(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").firstMatch(in: addbug.reason)?.matchedString
//                                    let second = Regex(":(Attempt|Modifications|CALayer|Set contentURL|.*?being enumerated)").firstMatch(in: bugr2.reason)?.matchedString
//                                    if first != second {
//                                        arr2.append(bugr2)
//                                    }
//                                }
//                            }
                        }
                    }
                    expect.fulfill()
                }
                self.waitForExpectations(timeout: 100)
            }
            
            
            xit("匹配oc方法的正则") {
                let orgStr = "-[UIScrollView removeAllSubViews]: unrecognized selector sent to instance 0x109129c00"
                let result = Regex("\\[.*?\\]").firstMatch(in: orgStr)?.matchedString
                print("匹配结果：\(result)")
            }
            
            xit("读取两天的数据，去重，生成电子表格") {
                JHBugly.parseJson(url, parameters: parameters) { bugArr in
                    //去重
                    let bugs = JHBugly.parseCSV(JHSources() + Path("bug.csv"))
                    let canAddArr = bugArr.compactMap{ newbug -> JHBuglyM? in
                        //bug name相同的
                        //reason 相同的
                        //控制器相同的
                        bugs.forEach { bug in
                            guard Regex("").matches(bug.reason) else {
                                //
                                return
                            }
                            return
                        }
                        return nil
                    }
                    //格式化表格打印
                    canAddArr.forEach { bug in
                        print(bug.description)
                    }
                }
            }
        }
    }
}

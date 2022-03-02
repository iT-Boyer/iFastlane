//
//  JHBugly.swift
//  CmdLib
//
//  Created by boyer on 2022/2/28.
//

import Foundation
import Alamofire
import SwiftyJSON
import GithubAPI
import Regex
import CSV
import PathKit

public struct JHBuglyM {
    public var currVC:String!
    public var lastVC:String!
    public var name:String!
    public var id:String!
    public var version:String!
    public var appname:String!
    public var appid:String!
    public var reason:String!
    public var reason_func:String?{
        Regex("-\\[.*?\\]").firstMatch(in: reason!)?.matchedString
    }
    public var detail:String!
    
    var description: String {
        """
        name: \(String(describing: name))
        reason: \(String(describing: reason))
        """
    }
}


class JHBugly {
    
    var url = "http://oms.iuoooo.com/MError/GetLogList?random=0.7724948616202214"
    static let parameters:[String:Any] = ["random": 0.9673897022258404,
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
    
    /**
      获取金和bug库的json数据
     */
    public static func parseJson(_ url:String, parameters:[String:Any], handler:@escaping([JHBuglyM])->Void){
        let request = URLRequest(url: URL(string: url)!)
        var urlRequest = try! URLEncoding.default.encode(request, with: parameters)
        urlRequest.headers["Content-Type"] = "application/json; charset=utf-8"
        urlRequest.headers["Accept"] = "application/json"
//        let semaphore = DispatchSemaphore(value: 0)
        AF.request(urlRequest).response {resp in
            if resp.response?.statusCode == 200 {
                let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                guard let dataStr = String(data: resp.data!, encoding: String.Encoding(rawValue: enc)) else { return }
                let datass = dataStr.data(using: .utf8)!
                let json = JSON(datass)
                let bugArr = parseJson(json)
                handler(bugArr)
//                semaphore.signal()
            }
        }
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    static func parseJson(_ json:JSON) -> [JHBuglyM] {
        var bugArr:[JHBuglyM] = []
        //读取resion
        let rows = json["rows"].arrayValue
        for row:JSON in rows {
            var bug = JHBuglyM()
            bug.id = row["id"].stringValue
            //其他信息:name/reason/version
            let cell = row["cell"].arrayValue
            bug.appname = cell[6].stringValue
            let content = cell[10].stringValue
            let reg = Regex(":.*\n",options: [.ignoreCase, .anchorsMatchLines])
            var index = 0
            _ = reg.allMatches(in: content).map { result in
//                let space = NSCharacterSet.whitespaces
                let returnstr = CharacterSet(charactersIn: "\n")
                let value = result.matchedString.trimmingCharacters(in: returnstr)
                switch index {
                case 0:
                    bug.currVC = value
                case 1:
                    bug.lastVC = value
                case 2:
                    bug.name = value
                case 3:
                    bug.reason = value
                default:
                    let version = Regex("\\d\\.\\d\\.\\d.\\d{1,}").firstMatch(in: content)?.matchedString
                    bug.version = version?.trimmingCharacters(in:returnstr)
                }
                index += 1
            }
            bugArr.append(bug)
        }
        return bugArr
    }
    
    public static func parseCSV(_ csv:Path)->[JHBuglyM] {
        var bugArr:[JHBuglyM] = []
        let stream = InputStream(fileAtPath: csv.string)!
        // hasHeaderRow must be true.
        let csv = try! CSVReader(stream: stream, hasHeaderRow: true)
//        let headerRow = csv.headerRow!
        while let row = csv.next() {
//            print("\(csv["Bug标题"]!)")
            var bug = JHBuglyM()
            bug.reason = csv["Bug标题"]!
            bug.detail = csv["重现步骤"]!
            bugArr.append(bug)
        }
        return bugArr
    }
}

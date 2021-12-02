import Foundation
import SwiftyJSON // https://github.com/SwiftyJSON/SwiftyJSON.git
import SwiftShell // https://github.com/kareman/SwiftShell
import Fastlane   // ~/hsg/fastlane
import Regex

extension Fastfile
{
    
    //runner lane ipFile value hostss
    func ipFileLane(withOptions options:[String: String]?) {
        if let value = options?["value"], value.count > 0{
            // Only when submit is true
            let ipFile = ipFile()
            let hosts = ipFile.hostList(keyword: value)
            if hosts.count == 0 {
                print("无数据")
            }else{
                for item in hosts {
                    let ky:Dictionary = item as! Dictionary<String, String>
                    print("\(ky)")
                }
            }
        }else{
            print("非法地址")
        }
    }
    
    //获取项目中的key和文件名称
    //runner lane ipProj proj projname
    func ipProjLane(withOptions options: [String : String]?)
    {
        if let value = options?["proj"], value.count > 0{
            // Only when submit is true
            let ipFile = ipFile()
            let iuooooPath = "/Users/boyer/Desktop/result-urls.json"
            let projDic:JSON = ipFile.loadJsonData(path: iuooooPath, proj: value)!
            print(projDic.rawValue)
        }else{
            print("非法地址")
        }
    }
    
}

class ipFile {
    //读取bundle文件路径
    //调用shell命令
    let ipfilePath = "/Users/boyer/hsg/JHMainApp/JHUniversalApp/JHUniversalApp/Resource/ipFile.plist"
    let iuooooPath = "/Users/boyer/Desktop/result-urls.json"
    //读取plist字典数据
    //匹配value 打印key
    
    //加载json文件中已经压缩过的targets
    func hostList(keyword:String) -> [Any] {
        let dicInfo:[String:String]! = NSDictionary(contentsOfFile: ipfilePath) as? [String : String]
        var hosts:[Any] = []
        for key:String in dicInfo.keys {
            let value = dicInfo[key]
            if value!.contains(keyword) {
                let host = [key:value!]
                hosts.append(host)
            }
        }
        return hosts;
    }
    
    //加载json文件中已经压缩过的targets
    func loadJsonData(path:String,proj:String) -> JSON? {
        
        let jsonData = NSData.init(contentsOfFile: path)! as Data
        // 项目名
        let projects = try! JSON(data: jsonData)
        // targets名
        //项目名称 key数组  m文件数组 是否clone
        for (projname,targetsJson):(String, JSON) in projects {
//          let targets:[String:Array] = subJson.rawValue as! [String : Array]
            if !projname.contains(proj) {
                continue
            }
            var dataDic:[String:Any] = [:]
            var filenames:[String] = []
            var ipfilekeys:[Any] = []
            var iustrkeys:[String] = []
            for (_,libsJson):(String, JSON) in targetsJson {
                
                for (libname,targetJson):(String, JSON) in libsJson {
                    
                    for (filen,linesJson):(String, JSON) in targetJson {
                        filenames.append(filen)
                        let lines:[String] = linesJson.rawValue as! [String]
                        for line in lines {
                            //正则匹配xxx.iuoooo.com
                            let regex = Regex("\\w*.iuoooo.com")
                            let iustr:String! = regex.firstMatch(in: line)?.matchedString
                            if iustrkeys.contains(iustr) {
                                continue
                            }
                            iustrkeys.append(iustr)
                            //在ipfile文件中查询key
                            let keys = hostList(keyword: iustr)
                            ipfilekeys.append(keys)
                        }
                    }
                }
            }
            dataDic["keys"] = iustrkeys
            dataDic["ipfilekeys"] = ipfilekeys
            dataDic["fileName"] = filenames
            let json:JSON = JSON(rawValue: dataDic)!
            return json
        }
        return nil
    }
}

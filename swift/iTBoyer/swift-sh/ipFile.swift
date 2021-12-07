import Foundation
import SwiftyJSON // https://github.com/SwiftyJSON/SwiftyJSON.git
import SwiftShell // https://github.com/kareman/SwiftShell
import Fastlane   // ~/hsg/fastlane
import Regex
import CmdLib

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
            let proJSON:JSON = ipFile.loadJsonData(path: iuooooPath, proj: value)!
            let files = proJSON["fileName"]
            let keys = proJSON["keys"]
//            let ipfilekeys = proJSON["ipfilekeys"]
            print("工作量：\(files.count)\n \(files.rawValue)")
            print("域名：\(keys)")
//            print("ipFile：\(ipfilekeys.rawValue)")
//            print(proJSON)
        }else{
            print("非法地址")
        }
    }
    
    
    
}

public class ipFile {
    
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
    func hostKey(host:String) -> String {
        let dicInfo:[String:String]! = NSDictionary(contentsOfFile: ipfilePath) as? [String : String]
        var hostKey = ""
        for key:String in dicInfo.keys {
            let value = dicInfo[key]
            if value == host {
                hostKey = key
                break
            }
        }
        return hostKey
    }
    
    func fetchSource(){
        //源码库清单
        let linkFile = "/Users/boyer/Desktop/all_link_path.h"
        //负责的库
        let ipgitfile = "/Users/boyer/Desktop/ipfileGit.txt"
        //本地源码目录
        let home = "/Users/boyer/hsg"
        SwiftShell.main.currentdirectory = home
        
        let link = SwiftShell.run(bash: "cat \(linkFile)").stdout
        let linkArr = link.split(separator: "\n")
        
        let ipgit = SwiftShell.run(bash: "cat \(ipgitfile)").stdout
        let ipgitArr = ipgit.split(separator: "\n")
        
        let hsg = SwiftShell.run(bash: "ls ./").stdout
        let currArr = hsg.split(separator: "\n")
        
//        var repos:[String] = []
//        for git in ipgitArr {
//            var exist = false
//            for dir in currArr {
//                if dir == git {
//                    exist = true
//                    break
//                }
//            }
//            if !exist {
//                repos.append(String(git))
//            }
//        }
        
        let repos = CmdTools.arrDiff(arr1: currArr, arr2: ipgitArr)
        print("待clone：\(repos)")
        //需要clone项目
        var urls:[String:String] = [:]
        for repo in repos {
            
            for link in linkArr {
                if link.contains(repo) {
                    urls[String(repo)] = String(link)
                    break
                }
            }
        }
        print(urls)
        
        for (key,url) in urls {
            
            do{
                let output = try runAsync("git","clone", "-b", "master", url).finish().stdout.read()
                print(output)
            }catch
            {
                print("\(key)：无权限")
            }
        }
    }
    
    //加载json文件中已经压缩过的targets
    func loadJsonData(path:String,proj:String) -> JSON? {
        
        let folder = "/Users/boyer/hsg/\(proj)"
        SwiftShell.main.currentdirectory = folder
        let dirstr = SwiftShell.run(bash: "find . -name \"JHUrlStringManager.h\"").stdout
        let dirArr = dirstr.split(separator: "\n")
        if dirArr.count > 0 {
            print("已添加工具包：JHUrlStringManager.h")
        }
        
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
            var filesArr:[String] = []
            var hostkeys:[String] = []
            for (_,libsJson):(String, JSON) in targetsJson {
                
                for (libname,targetJson):(String, JSON) in libsJson {
                    
                    for (filen,linesJson):(String, JSON) in targetJson {
                        let filestr = SwiftShell.run(bash: "find . -name \"\(filen)\"").stdout
                        let fileDir = filestr.split(separator: "\n")
                        
                        if let ocfile:NSString = fileDir.first as NSString? {
                            filesArr.append(ocfile as String)
                        }
                        let lines:[String] = linesJson.rawValue as! [String]
                        for line in lines {
                            //正则匹配xxx.iuoooo.com
                            let regex = Regex("[^\\\"@]*iuoooo.com")
                            let host:String! = regex.firstMatch(in: line)?.matchedString
                            var isexist = false
                            for hostkey in hostkeys {
                                if hostkey.contains(host) {
                                    isexist = true
                                    break
                                }
                            }
                            if !isexist {
                                //在ipfile文件中查询key
                                let hostKey = hostKey(host:host)
                                hostkeys.append(hostKey+":"+host)
                            }
                        }
                    }
                }
            }
            dataDic["keys"] = hostkeys
            dataDic["fileName"] = filesArr
            let json:JSON = JSON(rawValue: dataDic)!
            return json
        }
        return nil
    }
}

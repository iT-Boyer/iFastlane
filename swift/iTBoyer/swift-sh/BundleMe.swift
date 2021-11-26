import Foundation
import SwiftyJSON // https://github.com/SwiftyJSON/SwiftyJSON.git
import SwiftShell // https://github.com/kareman/SwiftShell
import Fastlane

extension Fastfile
{
    func bundleLane() {
        let bund = Bundle()
        bund.bundleMe()
    }
}

class Bundle {
    //读取bundle文件路径
    //调用shell命令
    
    //shell命令查找主工程中的所有bundle,返回bundle的名称
    func findBundleInPath(path:String) -> [String]
    {
        SwiftShell.main.currentdirectory = path
        //find . -name \"*.bundle\"
        let dirstr = SwiftShell.run(bash: "find . -name \"*.bundle\"").stdout
        let dirArr = dirstr.split(separator: "\n")
        var bundles:[String] = []
        for item in dirArr {
            let path:NSString = item as NSString
            let file:NSString = path.lastPathComponent as NSString
            let name = file.deletingPathExtension
            bundles.append(name)
        }
        return bundles
    }
    
    //加载json文件中已经压缩过的targets
    func loadJsonData(path:String) -> [String] {
        //找出历史记录
        var historyArr:Array<String> = []
        
        let jsonPath = path
        let projData = NSData.init(contentsOfFile: jsonPath)! as Data
        let projects = try! JSON(data: projData)
        // If json is .Dictionary
        for (key,subJson):(String, JSON) in projects {
            let subarr:Array<String> = subJson.rawValue as! Array<String>
            historyArr.append(contentsOf: subarr)
        }
        return historyArr
    }
    
    // 根据文件大小排序未统计的bundle清单
    func sortTodoBundleBySize(todo:[String]) {
        //大小排序，打印bundle大小和路径
        let sortBySizeStr = SwiftShell.run(bash: "find . -name \"*.bundle\" -print0 | xargs -0 du -sh | sort -hr").stdout
        let sortBySize = sortBySizeStr.split(separator: "\n")
        for item in sortBySize {
            for todo in todo {
                if item.contains(todo+".bundle") {
                    print(item)
                    desc("\(item)")
//                    echo(message:"\(item)")
                    break
                }
            }
        }
    }

    func bundleMe() {
        
        let bundles = findBundleInPath(path: "/Users/boyer/hsg/JHMainApp")
        
        let historyArr = loadJsonData(path: "/Users/boyer/Desktop/result-targets.json")
        
        //对比两个target数组，收集未统计到的bundle集合
        var todoBundle:[String] = []
        for bundle in bundles {
            //
            if !historyArr.contains(bundle) {
                todoBundle.append(bundle)
            }
        }
        //
        sortTodoBundleBySize(todo: todoBundle)
    }
}



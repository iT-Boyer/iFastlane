import Foundation
import SwiftyJSON // https://github.com/SwiftyJSON/SwiftyJSON.git
import SwiftShell // https://github.com/kareman/SwiftShell
import Fastlane

extension Fastfile
{
    func bundleLane() {
        let bund = Bundle()
        let todoBundle = bund.bundleMe()
        bund.sortTodoBundleBySize(todo: todoBundle)
    }
    
    func bundlezipTestLane(withOptions options:[String: String]?) {
        
        if let name = options?["name"], name == "hsg",
            let say:String = options?["say"], say.count > 0{
            // Only when submit is true
            echo(message: "：\(name)向你说：\(say)")
        }
    }
    
    //压缩目录下文件
    //runner lane optimgzip dir /Users/boyer/Desktop/img
    func optimgzipLane(withOptions options:[String: String]?) {
        let bund = Bundle()
        if let dir = options?["dir"], dir.count > 0{
            // Only when submit is true
            echo(message: "路径：\(dir)")
            bund.zipcmd(folder: dir)
        }else{
            print("非法地址")
        }
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
    
    func bundlezip(bundles:[String]) {
        let todoPath = SwiftShell.run(bash: "find . -name \"*.bundle\"").stdout
        let todoPathArr = todoPath.split(separator: "\n")
        for item in todoPathArr {
            for todo in bundles {
                if item.contains(todo+".bundle") {
                    print(item)
                    let bundlePath = "/Users/boyer/hsg/JHMainApp"+item
                    //进入bundle目录，开始执行压缩命令
                    zipcmd(folder: bundlePath)
                }
            }
        }
    }
    
    func zipcmd(folder:String) {
        SwiftShell.main.currentdirectory = folder
        let pngPath = SwiftShell.run(bash: "find . -name \"*.png\"").stdout
        let pngArr = pngPath.split(separator: "\n")
//        echo(message: "图片路径：\(pngArr)")
        let optimageCMD = "/Applications/Optimage.app/Contents/MacOS/cli/optimage"
        let output = try! runAsync(optimageCMD, "--lossy", pngArr).finish().stdout.read()
        print(output)
    }

    func bundleMe()->Array<String> {
        
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
        return todoBundle
    }
}



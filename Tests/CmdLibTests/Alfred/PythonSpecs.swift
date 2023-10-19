//
//  AlfredWorkflowSpecs.swift
//  Runner
//
//  Created by boyer on 2022/7/14.
//  
//

import Quick
import Nimble
import PythonKit
import Foundation
import SwiftyJSON
import AlfredSwift

class PythonSpecs: QuickSpec {
    override class func spec() {
        
        beforeSuite {
            //设置使用的版本
            PythonLibrary.useVersion(3)
            
            let sys = Python.import("sys")
            sys.path.append("/Users/boyer/hsg/iFastlane/Resources/Alfred/workflow")
            sys.path.append("/Users/boyer/hsg/iFastlane/Tests/CmdLibTests/Alfred")
            print("路径：\(sys.path)")
            print("Python \(sys.version_info.major).\(sys.version_info.minor)")
            print("Python Version: \(sys.version)")
            // 设置编码格式
            // sys.setdefaultencoding("utf8")
            print("Python Encoding: \(sys.getdefaultencoding().upper())")
        }
        
        describe("加载python脚本") {
            beforeEach {
                
            }
            
            xit("加载python文件调用方法") {
                let example = Python.import("helloWorld") // import your Python file.
                let name = "校长"
                let sex = "男"
                let response = example.hello(name, sex) // call your Python function
                print(response)
            }
            
            xit("请求接口解析数据") {
                
                waitUntil(timeout: .seconds(2)) { done in
                    URLSession.shared.dataTask(with: URL(string: "https://api.zhihu.com/topstory/hot-list")!) { data, response, error in
                        
                        if error != nil{
                                print(error!)
                            }else{
                                //Unicode
//                                var str = String(data: data!, encoding: String.Encoding.utf8)
//                                str = str?.data(using: .unicode)
//                                 print(str!)
                                
                                //解析
                                let json: JSON = try! JSON(data:data!)
                                let posts = json["data"]
                                print(json.description)
        //                        sendAlfredBySwift(posts)
        //                        sendAlfredByPythonKit(posts)
//                                workflow(posts)
//                                //退出命令
//                                hot_cli.Checkhot.exit()
                        }
                        done()
                    }.resume()
                }
            }
            
            xit("workflow演示") {
                let wfmodel = Python.import("workflow") // import your Python file.
                let wf = wfmodel.Workflow()
                for i in 0..<4
                {
                    // call your Python function
                    wf.add_item(title:"title\(i)",subtitle:"子标题\(i)",arg:"参数\(i)",icon:"./icon.png")
                }
                //Send the results to Alfred as XML
                wf.send_feedback()
            }
            
            it("alfredswift版本") {
                let wf = Alfred()
                for i in 0..<4
                {
                    let target = "target\(i)"
                    let title = "title\(i)"
                    wf.AddResult("temp\(i)", arg: "", title: title, sub: title, icon: "", valid: "", auto: "", rtype: "")
                }
                print(wf.ToXML())
            }
        }
    }
}

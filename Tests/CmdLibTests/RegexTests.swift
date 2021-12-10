//
//  RegexTests.swift
//  Runner
//
//  Created by boyer on 2021/12/10.
//  
//

import Quick
import Nimble
import Regex
import PathKit
class RegexTests: QuickSpec {
    override func spec() {
        describe("练习正则") {
            it("练习正则：打印匹配regexDemo清单") {
                //方案一
                //cat grep正则 查找
                //替换 sed 替换 写入文件
                //方案二
                //1 path.read
                //2 Regex正则输入
                let file1 = Path(#file).parent().parent()+Path("Resources/regexDemo.md")
                let filetxt:String = try! file1.read()
                print("文件：\(filetxt)")
                let reg = Regex.init(".*(\"api_host|iuooo|ipFile\").*\n",options: [.ignoreCase, .anchorsMatchLines])
                let matchingLines = reg.allMatches(in: filetxt).map {
                    $0.matchedString
                }
                print("在\(file1.lastComponent)中\n匹配到的行：\(matchingLines)")
                
                //3 regex正则替换
                let result = filetxt.replacingFirst(matching: "public", with: "H$1, $2!")
                print(result)

                //4 path.write 更新文件
//                try! file1.write(result)
            }
        }
    }
}

//
//  RegexTests.swift
//  Runner
//
//  Created by boyer on 2021/12/10.
//  
//
import Foundation
import Quick
import Nimble
import Regex
import PathKit
import CmdLib
class RegexTests: QuickSpec {
    override class func spec() {
        describe("练习正则") {
            it("练习正则：打印匹配regexDemo清单") {
                //方案一
                //cat grep正则 查找
                //替换 sed 替换 写入文件
                //方案二
                //1 path.read
                //2 Regex正则输入
//                let file1 = Path(#file).parent().parent()+Path("Resources/regexDemo.md")
                let file1 = Resources()+"regexDemo.md"
                let filetxt:String = try! file1.read()
//                print("文件：\(filetxt)")
                let reg = Regex.init(".*(\"api_host|iuooo|ipFile\").*\n",options: [.ignoreCase, .anchorsMatchLines])
                let matchingLines = reg.allMatches(in: filetxt).map { resul -> String? in
                    var str = resul.matchedString
//             str.contains("JHUrlStringManager") || str.contains("fullURL(with") || str.contains("domain(for")
                    guard Regex("JHUrlStringManager\\.{0,1}|JHBaseDomain").matches(str) else {
                        // 删除行前空格
                        let space = NSCharacterSet.whitespaces
                        str = str.trimmingCharacters(in: space)
                        if str.hasPrefix("//")
                            || str.contains("if ([api_host_adm")
                        {
                            return nil
                        }
                        print("存在：\(str)")
                           return str
                    }
                    return nil
                }
//                print("在\(file1.lastComponent)中\n匹配到的行：\(matchingLines)")
                
                //3 regex正则替换
//                let result = filetxt.replacingFirst(matching: "public", with: "H$1, $2!")
//                print(result)

                //4 path.write 更新文件
//                try! file1.write(result)
            }
        }
    }
}

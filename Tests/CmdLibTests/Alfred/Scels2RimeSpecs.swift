//
//  File.swift
//  
//
//  Created by boyer on 2023/10/21.
//

import Foundation
import Quick
import Nimble
import SwiftShell
import PathKit
@testable import CmdLib

class Scels2RimeSpecs:QuickSpec
{
    override class func spec(){
        
        var original_files:String = "~/Downloads/王者荣耀.scel"
        var yaml_tmpfile = "../tmp.yaml"
        var rime_dic = Path.home + "hsg/rime-trime/chatgpt-prompts.dict.yaml"
        
        beforeSuite {
//             命令介绍 https://github.com/studyzy/imewlconverter/wiki/CommandLine
            let ImeWlConverterCmd = Path.home + "/Users/boyer/hsg/imewlconverter/src/ImeWlConverterCmd/bin/Debug/net6.0/ImeWlConverterCmd.dll"
            //输出 rime yaml 格式文件
            SwiftShell.run(bash: "/opt/homebrew/bin/dotnet \(ImeWlConverterCmd) -i:scel \(original_files) -o:rime \(yaml_tmpfile)")
        }
        
        //制作 rime 词典，先了解词典的格式，是简单的 yaml 格式。
        //实现：在 scel 转换后的文件头部添加 dicstr 前缀。
        xdescribe("制作 rime 词库脚本迁移") {
            it("拼接字符串，存入到rime的词典文件"){
                var dicStr = """
                  ---
                  name: rime-scels
                  version: "1.0"
                  sort: by_weight
                  use_preset_vocabulary: true
                  # 此处为扩充词库（基本）默认链接载入的词库
                  # import_tables:
                  # - luna_pinyin
                  # - luna_pinyin.sogou
                  ...
                  
                  """
                print("--------")
                try! rime_dic.write(dicStr)
            }
        }
    }
}

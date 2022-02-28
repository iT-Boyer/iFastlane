//
//  SSHSpecs.swift
//  Runner
//
//  Created by boyer on 2022/2/15.
//  
//

import Quick
import Nimble
import Shout
import SwiftyJSON
/**
 1. 使用ssh 解析Test 环境的日志文件，获取下载ipa下载路径
 2. 使用ssh 拷贝远程文件到本地联调工程
 */
class SSHSpecs: QuickSpec {
    override func spec() {
        describe("链接设备") {
            it("链接Test服务器") {
                let ssh = try SSH(host: "ipa.fileserver.iuoooo.com")
                try ssh.authenticate(username: "TestServer", privateKey: "~/.ssh/id_rsa")
//                try ssh.execute("ls -a")
//                try ssh.execute("pwd")
                let grep = "grep 'http' Desktop/AutoPackage/logs/*\\.log"
//                let status = try ssh.execute(grep)
                let (status, output) = try ssh.capture(grep)
                print(output)
                let ls = "ls -a"
                let (status1, output1) = try ssh.capture(ls)
                print(output1)
            }
        }
    }
}

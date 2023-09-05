//
//  File.swift
//  
//
//  Created by boyer on 2023/9/4.
//

import Foundation
import Quick
import Nimble
import SwiftShell

/*
 模式多线程执行 shell 命令
 */
class SwiftShellSpecs: QuickSpec {

    override class func spec() {
        
        xdescribe("shell 命令") {
            
            // 使用队列组来管理多线程的资源
            fit("多线程同步shell命令") {
                let group = DispatchGroup()
                for i in 1..<3 {
                    group.enter()
                    DispatchQueue.global().async {
                        print("线程\(i) 开始：\(Thread.current)")
                        try? SwiftShell.runAndPrint("pwd")
                        print("线程\(i) 结束：\(Thread.current)")
                        group.leave()
                    }
                }
                var complated = false
                group.notify(queue: DispatchQueue.main) {
                    complated = true
                }
                while !complated {
                    print("等待.....")
                    sleep(1)
                }
                print("完成下载！！！！")
                
//                waitUntil(timeout: .seconds(20)) { done in
//                    group.notify(queue: DispatchQueue.main) {
//                     done()
//                    }
//                }
            }
            
            
            it("多线程异步shell命令") {
                let group = DispatchGroup()
                for i in 1..<3 {
                    group.enter()
                    let cmd = "echo 下载\(i)开始"
                    SwiftShell.runAsyncAndPrint(bash: cmd).onCompletion { cmd in
                        print("下载\(i)完成：\(Thread.current)")
                        group.leave()
                    }
                }
                
                waitUntil(timeout: .seconds(10)) { done in
                    group.notify(queue: DispatchQueue.main) {
                        //执行主线程命令
                        print("完成下载！！！！")
                        done()
                    }
                }
            }
        }
        
        xdescribe("线程阻塞") {
            
            fit("使用while阻塞") {
                var cmdArr:[PrintedAsyncCommand]! = []
                for i in 1..<5{
                    let shell = "echo 下载\(i)"
                    let cmd = SwiftShell.runAsyncAndPrint(bash: shell)
                    cmdArr.append(cmd)
                }
                
                while cmdArr.allSatisfy({$0.isRunning == true}){
                    print("等待...")
                    sleep(1)
                }
                print("下载完成")
            }
            
            it("使用Nimble工具阻塞") {
                //' wait until '的同步版本在异步上下文中不起作用。使用具有相同名称的async版本作为插入式替换
                waitUntil { done in
                    done()
                }
            }
        }
        
        describe("信号量") {
            fit("开启5个线程，处理10个文件") {
                let queue = DispatchQueue(label: "audioConvertQueue")
                let semaphore = DispatchSemaphore(value: 6)
                
                let total = 40
                var completed = 0
                
                waitUntil(timeout: .seconds(10)) { done in
                    for i in 1...total {
                        semaphore.wait()
                        
                        queue.async {
                            let shell = "echo 下载\(i):\"\(Thread.current)\""
                            SwiftShell.runAsyncAndPrint(bash:shell).onCompletion { cmd in
                                completed += 1
                                print("下载\(i)完成：\(completed)个")
                                semaphore.signal()
                                
                                if completed == total {
                                    print("All files converted")
                                    done()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

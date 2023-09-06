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
 问题清单：
 1. 在终端单元测试里，队列组group无法得到队列notify通知
    解决办法：使用Nimble waitUntil 函数。
 2.
 */
class SwiftShellSpecs: QuickSpec {

    override class func spec() {
        
        var bashCmds:[String]!
        beforeSuite {
            bashCmds = ["echo 任务1", "echo 任务2", "echo 任务3", "echo 任务4"]
        }
        
        xdescribe("在终端命令中，group队列组无法得到队列notify通知") {
            var group:DispatchGroup!
            beforeEach {
                group = DispatchGroup()
            }
            
            afterEach {
                var complated = false
                group.notify(queue: DispatchQueue.main) {
                    complated = true
                }
                while !complated {
                    print("等待.....")
                    Thread.sleep(forTimeInterval: 1)
                }
                print("完成下载！！！！")
                
                //                waitUntil(timeout: .seconds(20)) { done in
                //                    group.notify(queue: DispatchQueue.main) {
                //                     done()
                //                    }
                //                }
            }
            
            // 使用队列组来管理多线程的资源
            fit("使用并行队列验证") {
                bashCmds.forEach { cmd in
                    group.enter()
                    DispatchQueue.global().async {
                        print("开始：\(Thread.current)")
                        try? SwiftShell.runAndPrint(bash:cmd)
                        print("结束：\(Thread.current)")
                        group.leave()
                    }
                }

            }
            
            xit("使用SwiftShell异步命令验证") {
                for i in 1..<3 {
                    group.enter()
                    let cmd = "echo 下载\(i)开始"
                    SwiftShell.runAsyncAndPrint(bash: cmd).onCompletion { cmd in
                        print("下载\(i)完成：\(Thread.current)")
                        group.leave()
                    }
                }
            }
        }
        
        describe("在终端命令中，实现线程阻塞的几个方法") {
            
            xit("方法1:使用while阻塞") {
                var cmdArr:[PrintedAsyncCommand]! = []
                for i in 1..<5{
                    let shell = "echo 下载\(i)"
                    let cmd = SwiftShell.runAsyncAndPrint(bash: shell).onCompletion { cmd in
                        print("完成\(i)")
                    }
                    cmdArr.append(cmd)
                }
                
                while cmdArr.allSatisfy({$0.isRunning == true}){
                    print("等待...\(Thread.current)")
                    Thread.sleep(forTimeInterval: 1)
                }
                print("下载完成")
            }
            
            fit("方法2:使用信号量阻塞") {
                // 最大限制3个线程执行任务
                let semaphore = DispatchSemaphore(value: 18)
                let total = 15
                var completed = 0
                var cmdArr:[PrintedAsyncCommand]! = []
                for i in 1...total {
                    semaphore.wait()
                    let shell = "echo 下载\(i):\"\(Thread.current)\""
                    let cmd = SwiftShell.runAsyncAndPrint(bash:shell).onCompletion { cmd in
                        completed += 1
                        semaphore.signal()
                        print("下载\(i)完成：\(completed)个")
                        if completed == total {
                            print("All files converted")
                        }
                    }
                    cmdArr.append(cmd)
                }
                print("开始等待...")
                let msg = cmdArr.compactMap { cmd -> Bool in
                    return cmd.isRunning
                }
                //转换进度状态
                print(msg)
                for cmd in cmdArr {
                    if cmd.isRunning {
                        print("等待...\(Thread.current)")
                        Thread.sleep(forTimeInterval: 1)
                        
                        let msg2 = cmdArr.compactMap { cmd -> Bool in
                            return cmd.isRunning
                        }
                        //转换进度状态
                        print(msg2)
                        break
                    }
                }
                print("下载完成=====")
            }
            
            it("方法二使用Nimble工具阻塞") {
                //' wait until '的同步版本在异步上下文中不起作用。使用具有相同名称的async版本作为插入式替换
                waitUntil { done in
                    done()
                }
            }
        }
        
        xdescribe("信号量") {
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

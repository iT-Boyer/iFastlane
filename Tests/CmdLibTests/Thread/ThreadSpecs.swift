//
//  ThreadSpecs.swift
//
//
//  Created by boyer on 2023/9/2.
//

import Foundation
import Quick
import Nimble
import SwiftShell
@testable import CmdLib

class ThreadSpecs:QuickSpec {
    override class func spec(){
        xdescribe("线程演练"){
            /* DispatchQueue 队列
             1. 创建串行队列：串行为默认创建的队列
             2. 向队列中添加block事件，并异步步执行
             */
            xit("串行队列，异步执行"){
                //串行队列
                let serialQueue = DispatchQueue.init(label: "串行队列")
                for i in 1 ... 3 {
                    serialQueue.async {
                        if i == 2{
                            Thread.sleep(forTimeInterval: 2)
                            //                            sleep(1)
                            print("\(Thread.current)---\(i)👌💕")
                        }else{
                            print("\(Thread.current)---\(i)👌💕")
                        }
                    }
                }
                //主线程
                for i in 101 ... 103 {
                    print("\(Thread.current)主线程：\(i)")
                }
            }
            
            fit("并行队列，异步执行") {
                //1. 创建并行队列 concurrent
                let concurrentQueue = DispatchQueue.init(label: "并行队列",
                                                         attributes: .concurrent,
                                                         target: nil)
                //2. 向队列中添加多个操作
                for i in 1 ... 3 {
                    concurrentQueue.async {
                        if i == 2 {
                            //等待2s，验证并行多线程，不影响执行其它操作
                            Thread.sleep(forTimeInterval: 2)
                            print("+++\(i):暂定2s\n\(Thread.current)")
                        }
                        print("子线程\(i)：\(Thread.current)---")
                    }
                }
                
                for i in 1 ... 3 {
                    print("主线程\(i)：\(Thread.current)")
                }
            }
        }
        
        describe("队列组") {
            /*
             队列组
             1. 自动依赖：使用队列的async方法即可
             2. 手动依赖：需要使用enter()/leave()
             场景：
             利用任务组可以完成很多场景的工作。例如多任务执行完后，统一刷新UI。把刷新UI的操作放在notify里面就好了。
             */
            
            var queueGroup:DispatchGroup!
            //创建在主线程上的并行队列
            var concurrentQueue:DispatchQueue!
            beforeEach {
                queueGroup = DispatchGroup()
                concurrentQueue = DispatchQueue(label: "mycurrentQueue", attributes: .concurrent ,target:nil)
            }
            
            xit("自动依赖") {
                //向并行队列添加任务
                concurrentQueue.async(group: queueGroup){
                    Thread.sleep(forTimeInterval: 4)
                    print("""
                        第一个队列操作任务
                        \(Thread.current)
                    """)
                }
                concurrentQueue.async(group: queueGroup){
                    Thread.sleep(forTimeInterval: 0.5)
                    print("第二个队列任务\n\(Thread.current)")
                }
                concurrentQueue.async(group: queueGroup){
                    print("第三个操作任务")
                }
                //进入主队列执行
                queueGroup.notify(queue: DispatchQueue.main){
                    print("更新UI\n\(Thread.current)")
                }
            }
            
            fit("手动依赖") {
                let manualGroup = DispatchGroup()
                //模拟循环建立几个全局队列
                for manualIndex in 0...3 {
                    //进入队列管理
                    manualGroup.enter()
                    DispatchQueue.global().async {
                        //让线程随机休息几秒钟：即在实际工作共处理大数据的地方
                        Thread.sleep(forTimeInterval: TimeInterval(arc4random_uniform(2) + 1))
                        print("-----手动任务\(manualIndex):\(Thread.current)执行完毕")
                        //配置完队列之后，离开队列管理
                        manualGroup.leave()
                    }
                }
                //发送通知
                waitUntil(timeout: .seconds(20)) { done in
                    manualGroup.notify(queue: DispatchQueue.main) {
                        print("手动任务组的任务都已经执行完毕啦！")
                        done()
                    }
                }
            }
            
            fit("自动依赖") {
                let autoGroup = DispatchGroup()
                //模拟循环建立几个全局队列
                for index in 0...3 {
                    //创建队列的同时，加入到任务组中
                    let workItem = DispatchWorkItem {
                        Thread.sleep(forTimeInterval: TimeInterval(arc4random_uniform(2) + 1))
                        print("任务\(index):\(Thread.current)执行完毕")
                    }
                    DispatchQueue.global().async(group: autoGroup, execute: workItem)
                }
                
                //组中所有任务都执行完了会发送通知
                waitUntil(timeout: .seconds(20)) { done in
                    autoGroup.notify(queue: DispatchQueue.main) {
                        print("任务组的任务都已经执行完毕啦！")
                        done()
                    }
                }
            }
        }
    }
}

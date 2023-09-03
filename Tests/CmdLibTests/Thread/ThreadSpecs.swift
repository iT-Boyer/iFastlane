//
//  ThreadSpecs.swift
//  
//
//  Created by boyer on 2023/9/2.
//

import Foundation
import Quick
import SwiftShell
@testable import CmdLib

class ThreadSpecs:QuickSpec {
    override func spec(){
        describe("线程演练"){
            /* DispatchQueue 队列
             1. 创建串行队列：串行为默认创建的队列
             2. 向队列中添加block事件，并异步步执行
             */
            it("串行队列，异步执行"){
                //串行队列
                let serialQueue = DispatchQueue.init(label: "串行队列")
                for i in 1 ... 3 {
                    serialQueue.async {
                        if i == 2{
                            sleep(1)
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
            
            it("并行队列，异步执行") {
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
    }
}

//
//  File.swift
//  
//
//  Created by boyer on 2023/9/6.
//

import Foundation
import SwiftShell

public struct CmdTasks {
    // 传入命令数组，开数组执行
    public static func runShell(cmds:[String])->String? {
        
        
        print("总任务数：\(cmds.count) 个")
        
        let taskmax = 5
        let semaphore = DispatchSemaphore(value: taskmax)
        let total = cmds.count
        var completed = 0

        let cmdArr = cmds.compactMap { bashCmd -> PrintedAsyncCommand? in
            semaphore.wait()
            return SwiftShell.runAsyncAndPrint(bash: bashCmd).onCompletion { cmd in
                completed += 1
                print("完成：\(completed)个")
                semaphore.signal()
            }
        }
        //使用 while cmdArr.allSatisfy({$0.isRunning == true}) 获取的运行状态会滞后。
        //直接使用 for 循环检索命令运行状态:有一个在运行，就sleep等待。
        for cmd in cmdArr{
            if cmd.isRunning {
                print("等待...")
                Thread.sleep(forTimeInterval: 1)
                break
            }
        }
        print("完成任务")
        
        let item = ResultModel(title:"完成任务",arg: "")
        return AlfredJSON(items: [item]).toJson()
    }
}

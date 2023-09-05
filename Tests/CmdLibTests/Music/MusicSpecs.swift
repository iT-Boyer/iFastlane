//
//  MusicSpecs.swift
//  
//
//  Created by boyer on 2023/9/1.
//

import Foundation
import PathKit
import SwiftShell
import AVFoundation
import AudioToolbox
import Quick
import Nimble

@testable import CmdLib
///目标：将wma 文件批量转为 mav 文件，然后导入到音乐app 中。
///1.  执行 ffmpeg 命令的两个参数：wma 文件 和 目标文件 mav
///从 /Volume/下载/目录下获取文件。可以参考 Ali 中的相关逻辑，获取wma 文件和绝对路径。
///执行shell 命令可以参考
class MusicSpecs: QuickSpec {
    override class func spec() {
        var wmaCmds:[String]!
        
        beforeSuite {
            // 获取指定目录下的所有WMA文件路径
            let fm = FileManager.default
//            let path = "/Users/boyer/Downloads/Test"
            let path =  "/Users/boyer/Downloads/Test"
            let to =  "/Volumes/AIGO/Media.localized/Automatically Add to Music.localized/"
            guard let directory = try? fm.contentsOfDirectory(atPath: path) else{ return }
            let wmaFiles = directory.filter { $0.hasSuffix(".wma") }
            wmaCmds = wmaFiles.compactMap { wmaFile -> String in
                let filename = (wmaFile as NSString).deletingPathExtension
                let wmaPath = path + "/\(filename).wma"
                let wavPath = to + "/\(filename).wav"
                return "/opt/homebrew/bin/ffmpeg -i \"\(wmaPath)\" -ar 16000 -ac 1 -c:a pcm_s16le \"\(wavPath)\" &> /dev/null"
            }
        }
        xdescribe("wma转wav文件") {
            
            xit("使用数组元素的状态") {
                // 循环每个WMA文件并转换为WAV
                let cmdArr = wmaCmds.compactMap { bashCmd -> PrintedAsyncCommand? in
                    return SwiftShell.runAsyncAndPrint(bash: bashCmd)
                }
                
                while cmdArr.allSatisfy({$0.isRunning == true}) {
                    let msg = cmdArr.compactMap { cmd -> Bool in
                        return cmd.isRunning
                    }
                    //转换进度状态
                    print(msg)
                    sleep(1)
                }
                print("下载完成")
            }
            
            xit("使用队列组判断多线程完成") {
                let group = DispatchGroup()
                // 循环每个WMA文件并转换为WAV
                _ = wmaCmds.map{ bashCmd in
                    group.enter()
                    SwiftShell.runAsyncAndPrint(bash: bashCmd).onCompletion { cmd in
                        group.leave()
                    }
                }
                var completed = false
                group.notify(queue: DispatchQueue.main) {
                    print("下载完成-----")
                    completed = true
                }
                while !completed {
                    sleep(1)
                }
                print("下载完成")
            }

            xit("使用信号量，开启多线程") {
                var semaphore = DispatchSemaphore(value: 5)
                let total = wmaCmds.count
                var completed = 0
                wmaCmds.forEach { cmd in
                    semaphore.wait()
                    SwiftShell.runAsyncAndPrint(bash: cmd).onCompletion { cmd in
                        completed += 1
                        print("完成：\(completed)个 \(Thread.current)")
                        semaphore.signal()
                        if completed == total{
                            print("下载完成")
                        }
                    }
                }
            }
            
            xit("使用队列组管理信号量，开启多线程") {
                //
                let convertQueue = DispatchQueue(label: "queue", qos: .userInitiated, attributes: .concurrent)
                let group = DispatchGroup()
                let maxConcurrency = 5
                let semaphore = DispatchSemaphore(value: maxConcurrency)

                let total = wmaCmds.count
                print("总文件数：\(total)")
                var completed = 0
                for cmd in wmaCmds{
                    group.enter()
                    semaphore.wait()
                    convertQueue.async(group: group) {
                        SwiftShell.run(bash:cmd)
                        completed += 1
                        print("完成：\(completed)个 \(Thread.current)")
                        group.leave()
                        semaphore.signal()
                    }
                }
                group.notify(queue: .main) {
                    print("下载完成")
                }
            }
        }
        
        describe("Ali工具集") {
            
            fit("测试1") {
                waitUntil(timeout: .seconds(1000)) { done in
                    _ = CmdLib.Ali.wmaTowav(path: "/Users/boyer/Downloads/Test")
                    done()
                }
            }
            
            xit("测试2") {
                waitUntil(timeout: .seconds(10)) { done in
                    let wma =  "/Volumes/下载/2018-2021抖音经典歌曲/2019年抖音精选"
                    _ = CmdLib.Ali.wmaTowav(path: wma)
                    done()
                }
            }
        }
    }
}

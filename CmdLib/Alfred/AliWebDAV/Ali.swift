//
//  File.swift
//  
//
//  Created by boyer on 2022/11/29.
//

import Foundation
import PathKit
import SwiftShell

public struct Ali {
    
    //生成播放列表
    public static func to(dir:String)->String? {
        //volumeDir:/Volumes/127.0.0.1/
        //$ aliyundrive-fuse -r b81d200fec5b4ed2ac2ce3e72162fa33 -w /var/run/aliyundrive-fuse ~/rclone/Ali
        // 使用aliyundrive-fuse工具简化云盘的挂载机制，m3u8只需要关注目录结构。
        // let aliPath = Path.home + ali + dir
        let aliPath = Path("/Volumes/下载/") + dir
        print("Duang盘:\(aliPath)")
        // let http = "http://192.168.31.244:8686/"
        let m3u = Path.home+"Desktop/\(Path(dir).lastComponent).m3u8"
        var item = ResultModel(title:m3u.lastComponent,arg: m3u.string)
        if aliPath.exists {
//            print("-----递归------")
            print("正在从ali盘中读取列表..")
            guard let childrens = try? aliPath.recursiveChildren() else { return nil}
            print("文件个数：\(childrens.count)")
            var content = ""
            let times = "0"
            let media = ["mp4", "mp3", "mp4a", "avi", "wav", "wma", "rmvb", "rm", "wmv", "flv", "m4a"]
            let _ = childrens.map { path in
                if path.string.contains(dir) {
                    if path.isFile && media.contains(path.extension!) {
                        let m3u8 = """
                          \n#EXTINF:\(times),\(path.lastComponentWithoutExtension)
                          \(path)
                          """
                        content.append(m3u8)
                    }
                }
            }
            //replacingOccurrences
            // content = content.replacingOccurrences(of: ali, with: http)
            try! m3u.write(content)
        }else{
            item.title = "目录不存在"
            item.arg = ""
        }
        return AlfredJSON(items: [item]).toJson()
    }
 
    public static func wmaTowav(path:String, to:String = "/Volumes/AIGO/Media.localized/Automatically Add to Music.localized/")->String?{
        let aliPath = Path(path)
        let toPath = Path(to)
        var item = ResultModel(title:"\(path)转换完成",arg:"")
        if aliPath.exists {
            print("正在从ali盘中读取列表..")
            guard let childrens = try? aliPath.recursiveChildren().filter({$0.string.hasSuffix(".wma")}) else { return nil }
            print("文件个数：\(childrens.count)")
            //最大限制5个线程
            let queue = DispatchQueue(label: "queue", attributes: .concurrent)
            let maxConcurrency = 5
            var semaphore = DispatchSemaphore(value: maxConcurrency)
            let total = childrens.count
            var completed = 0
            _ = childrens.map { wmaPath in
                let filename = wmaPath.lastComponentWithoutExtension
                let wavPath = toPath + "\(filename).wav"
                let bashCmd = "/opt/homebrew/bin/ffmpeg -i \"\(wmaPath)\" -ar 16000 -ac 1 -c:a pcm_s16le \"\(wavPath)\" &> /dev/null"
                semaphore.wait()
                print("开始：\(filename)")
//                queue.async {
//                    let sucess = SwiftShell.run(bash:bashCmd).succeeded
//                    if sucess {
//                        completed += 1
//                        let num = semaphore.signal()
//                        print("转换完成：\(completed)个，当前信号量： \(num)个 \(Thread.current)")
//                        if completed == total {
//                            print("全部完成")
//                            //                        try? wmaPath.delete()
//                        }
//                    }
//                    
//                }
                SwiftShell.runAsync(bash: bashCmd).onCompletion { cmd in
                    completed += 1
                    let concurrency = min(total - completed, maxConcurrency)
                    semaphore = DispatchSemaphore(value: concurrency)
                    if completed == total {
                        print("下载完成")
//                        try? wmaPath.delete()
                    }
                    let num = semaphore.signal()
                    print("转换完成：\(completed)个，当前信号量： \(num)个")
                }
            }
        }else{
            item.title = "目录不存在"
            item.arg = ""
        }

        return AlfredJSON(items: [item]).toJson()
    }
}

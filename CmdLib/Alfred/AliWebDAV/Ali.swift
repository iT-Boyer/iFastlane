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
        let ali = "rclone/Ali"
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
//            print("-----递归------")
            print("正在从ali盘中读取列表..")
//            .filter{ $0.string.hasSuffix("wma") }
            guard let childrens = try? aliPath.recursiveChildren() else { return nil }
            print("文件个数：\(childrens.count)")
            
            let media = ["mp3", "wav", "wma", "m4a"]
            let _ = childrens.map { path in
                if path.isFile && media.contains(path.extension ?? "") {
                    // 当是 wma 时，开始转换
                    if path.extension == "wma" {
                        let filename = path.lastComponentWithoutExtension
                        let wavPath = toPath + "\(filename).wav"
                        let bashCmd = "ffmpeg -i \"\(path)\" -ar 16000 -ac 1 -c:a pcm_s16le \"\(wavPath)\""
                        print("开始转换:\(filename).wav--:\n\(bashCmd)")
                        SwiftShell.runAsync(bash: bashCmd).onCompletion { cmd in
                            print("测试结果:-----\(cmd.isRunning)")
                            print("完成转换：\(filename).wav")
                        }
                    }else{
                        // 拷贝到 音乐 app
//                        try? path.copy(toPath)
                    }
                    // 移除文件
//                    try? path.delete()
                }
            }
        }else{
            item.title = "目录不存在"
            item.arg = ""
        }

        return AlfredJSON(items: [item]).toJson()
    }
}

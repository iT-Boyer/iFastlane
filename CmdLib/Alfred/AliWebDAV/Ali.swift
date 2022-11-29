//
//  File.swift
//  
//
//  Created by boyer on 2022/11/29.
//

import Foundation
import PathKit
public struct Ali {
    
    public static func to(dir:String)->String? {
        //volumeDir:/Volumes/127.0.0.1/
        let ali = "/Volumes/127.0.0.1/"
        let aliPath = Path(ali+dir)
        let http = "http://192.168.31.244:8686/"
        let m3u = Path.home+"Desktop/\(Path(dir).lastComponent).m3u8"
        if aliPath.exists {
//            print("-----递归------")
            guard let childrens = try? aliPath.recursiveChildren() else { return nil}
//            print("文件个数：\(childrens.count)")
            var content = ""
            let times = "0"
            let media = ["mp4", "mp3", "mp4a", "avi", "wav", "wma"]
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
            content = content.replacingOccurrences(of: ali, with: http)
            try! m3u.write(content)
        }
        let item = ResultModel(title:m3u.lastComponent,arg: m3u.string)
        return AlfredJSON(items: [item]).toJson()
    }
}

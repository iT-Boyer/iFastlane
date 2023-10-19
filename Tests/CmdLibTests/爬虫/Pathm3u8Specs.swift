//
//  Pathm3u8Specs.swift
//  Runner
//
//  Created by boyer on 2022/7/12.
//  
//

import Quick
import Nimble
import PathKit
import SwiftFFmpeg

//let repoProjs = try! repo.recursiveChildren()
//错误：Generic parameter 'ElementOfResult' could not be inferred
//        repoProjs.compactMap{ proj in
//                                if proj.match("*.xcodeproj") {
//                                    let pp:Path = proj
//                                    return pp
//                                }
//                                return nil
//                                print("\(proj)")
//        }
//通配符：仅支持对当前目录匹配，无法递归所有目录
//        let pattern = ("**/*.xcodeproj").description
//                            let paths = Path.glob(pattern)
//        let paths = repo.glob(pattern)
//        print("proj文件：\(paths)")

class Pathm3u8Specs: QuickSpec {
    override class func spec() {
        
        
        describe("加载Ali目录") {
            
            let ali = Path("\(Path.home)/rclone/Ali")
//            let ali = Path("\(Path.home)/hsg/iFastlane/Tests")
            let http = "http://localhost:8686/"
            let m3u = Path.home+"Desktop/vlc.m3u8"
            let directory = Path("极客时间/70-算法面试通关40讲")
            let alil = ali + directory
            beforeEach {
                
            }
            it("读取ali目录信息") {
                
                if alil.exists {
                    print("-----递归------")
                    guard let childrens = try? alil.recursiveChildren() else { return }
                    var content = ""
                    let _ = childrens.map { pp in
                        if pp.isDirectory {
                           let _ = pp.glob("*mp4").map{ jj in
                                var times = "0"
//                                if let fmtCtx = try? AVFormatContext(url: jj.string)
//                                {
//                                    if let _ = try? fmtCtx.findStreamInfo(){
//                                        times = self.transToHourMinSec(time: fmtCtx.duration/1000000)
//                                    }
//                                }
                                
                                let filename = pp.lastComponent
                                let filePath = http + (directory + filename + jj.lastComponent).string
                                
                                let m3u8 = """
                                    \n#EXTINF:\(times),\(pp.lastComponentWithoutExtension)
                                    \(filePath)
                                    """
                               content.append(m3u8)
                            }
                        }else{
                            var times = "0"
//                            if let fmtCtx = try? AVFormatContext(url: pp.string)
//                            {
//                                if let _ = try? fmtCtx.findStreamInfo(){
//                                    times = self.transToHourMinSec(time: fmtCtx.duration/1000000)
//                                }
//                            }
                            
                            let filePath = http + (directory + pp.lastComponent).string
                            
                            let m3u8 = """
                                \n#EXTINF:\(times),\(pp.lastComponentWithoutExtension)
                                \(filePath)
                                """
                            content.append(m3u8)
                        }
                    }
                    
                    try! m3u.write(content)
                }
            }
        }
    }
    
    // MARK: - 把秒数转换成时分秒（00:00:00）格式
    ///
    /// - Parameter time: time(Float格式)
    /// - Returns: String格式(00:00:00)
    func transToHourMinSec(time: Int64) -> String
    {
        let allTime: Int = Int(time)
        var hours = 0
        var minutes = 0
        var seconds = 0
        var hoursText = ""
        var minutesText = ""
        var secondsText = ""
        
        hours = allTime / 3600
        hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
        
        minutes = allTime % 3600 / 60
        minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        seconds = allTime % 3600 % 60
        secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        return "\(hoursText):\(minutesText):\(secondsText)"
    }
}

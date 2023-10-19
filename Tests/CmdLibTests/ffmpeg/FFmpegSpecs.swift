//
//  FFmpegSpecs.swift
//  Runner
//
//  Created by boyer on 2022/7/21.
//  
//
import Foundation
import Quick
import Nimble
import SwiftFFmpeg
import PathKit

class FFmpegSpecs: QuickSpec {
    override class func spec() {
        
        var videoPath:Path!
        beforeSuite {
            videoPath = Path.home + Path("Desktop/学习/混沌研习社/12.m4a")
        }
        
        describe("获取视频基础信息") {
            
            var fmtCtx:AVFormatContext!
            beforeEach {
                if videoPath.exists{
                    let context = try? AVFormatContext(url: videoPath.string)
                    fmtCtx = context
                }
            }
            
            it("视频时长") {
                //如何利用 AVDictionary 配置参数（转）:https://www.cnblogs.com/xihong2014/p/6711051.html
                let option:[String:String] = ["probesize":"4096"]
                guard let _ = try? fmtCtx.findStreamInfo(options: [option]) else{return}
//                for (k, v) in fmtCtx.metadata {
//                  print("\(k): \(v)")
//                }
                fmtCtx.dumpFormat(isOutput: false)
                let can = fmtCtx.flags.description
                print("tiiii:\(can)")
//                fmtCtx.set(<#T##value: String##String#>, forKey: <#T##String#>)
                let jj = try fmtCtx.string(forKey: "max_streams")
                print("获取市场：\(jj)")
                let pps = fmtCtx.supportedOptions.compactMap { opt -> String in
                    opt.name
                }
                print("支持的：\(pps)")
                let pp = fmtCtx.durationEstimationMethod
                let ps = AVDurationEstimationMethod.fromPTS.rawValue
                let duration = fmtCtx.duration/1000000 //微妙换算秒单位
                print("时长1：\(fmtCtx.duration)")
                print("时长：\(duration.secondsToTime())")
            }
            
        }
    }
}

extension Int64 {

    func secondsToTime() -> String {

        let (h,m,s) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)

        let h_string = h < 10 ? "0\(h)" : "\(h)"
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"

        return "\(h_string):\(m_string):\(s_string)"
    }
}

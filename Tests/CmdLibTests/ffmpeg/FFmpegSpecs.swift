//
//  FFmpegSpecs.swift
//  Runner
//
//  Created by boyer on 2022/7/21.
//  
//

import Quick
import Nimble
import SwiftFFmpeg
import PathKit

class FFmpegSpecs: QuickSpec {
    override func spec() {
        
        var videoPath:Path!
        beforeSuite {
            videoPath = Path.home + Path("Desktop/学习/混沌研习社/“时间简史”曹天元丨不确定性思维：_ 从章鱼保罗看成功与运气的必然联系.m4")
        }
        
        describe("获取视频基础信息") {
            
            var fmtCtx:AVFormatContext!
            beforeEach {
                let context = try? AVFormatContext(url: videoPath.string)
                fmtCtx = context
            }
            
            it("视频时长") {
                let option:[String:String] = ["Duration":""]
                guard let _ = try? fmtCtx.findStreamInfo(options: [option]) else{return}
                for (k, v) in fmtCtx.metadata {
                  print("\(k): \(v)")
                }

            }
            
        }
    }
}

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
    override func spec() {

        var wmaFile:Path!
        beforeSuite {
            wmaFile = Path("/Users/boyer/Downloads/A Kind  of  Sorrow—[A-Lin].wma")
        }
        
        describe("wma 转 wav 文件") {
            
            xit("wmafile 调用") {
                self.wmaFile(path: "/Volumes/下载/2018-2021抖音经典歌曲/2019年抖音精选")
            }
            
            xit("使用 shell ") {
                self.wmaToWav(wmaPath: wmaFile)
            }
            
            fit("集成到Ali 工具") {
                waitUntil(timeout: .seconds(10)) { done in
                    _ = CmdLib.Ali.wmaTowav(path: "/Users/boyer/Downloads/Test")
                    done()
                }
            }
        }
    }
    
    func wmaToWav(wmaPath:Path) {
        let filename = wmaPath.lastComponentWithoutExtension
        let musicRoot = Path("/Volumes/AIGO/Media.localized/Automatically Add to Music.localized/")
        let wavPath = musicRoot + "\(filename).wav"
        
        let bashCmd = "/opt/homebrew/bin/ffmpeg -i \"\(wmaPath)\" -ar 16000 -ac 1 -c:a pcm_s16le \"\(wavPath)\""
        _ = SwiftShell.runAsyncAndPrint(bash: bashCmd)
    }
    
    func wmaFile(path:String) {
        // 获取指定目录下的所有WMA文件路径
        let fm = FileManager.default
        guard let directory = try? fm.contentsOfDirectory(atPath: path) else{ return }
        let wmaFiles = directory.filter { $0.hasSuffix(".wma") }
        
        // 循环每个WMA文件并转换为WAV
        for wmaFile in wmaFiles {
          let apath = (path as NSString).appendingPathComponent(wmaFile)
          let wmaUrl = URL(fileURLWithPath: apath)
          let wavUrl = wmaUrl.deletingPathExtension().appendingPathExtension("m4a")

          // 使用AVAssetExportSession进行格式转换
          let asset = AVAsset(url: wmaUrl)
//          let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
          var preset: String = AVAssetExportPresetAppleM4A
//          exportSession.supportedFileTypes.contains(AVFileTypeMPEG4)
          guard let exportSession = AVAssetExportSession(asset: asset, presetName: preset)else {
            return
          }
          exportSession.outputURL = wavUrl
          exportSession.outputFileType = AVFileType.m4a
          exportSession.exportAsynchronously {
            // export complete
              print(exportSession.error ?? "")
          }
        }

        print("WMA to WAV conversion complete.")
    }
}

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
    override func spec() {
        
        
        describe("加载Ali目录") {
            
//            let ali = Path("~/rclone/Ali")
            let ali = Path("\(Path.home)/hsg/iFastlane/Tests")
            let http = "http://localhost:8686"
            let m3u = Path.home+"/Desktop/vlc.m3u8"
            beforeEach {
                
            }
            it("读取ali目录信息") {
                
                if ali.exists {
                    print("-----递归------")
                    guard let childrens = try? ali.recursiveChildren() else { return }
                    childrens.map { pp in
                        if pp.isDirectory {
                            print(pp.lastComponent)
                            pp.glob("*swift").map { jj in
                                print("--"+jj.lastComponent)
                            }
                        }
                        
                    }
                }
            }
            
            xit("获取目录下的视频") {
                
                let videoPath = ali + ""
                
                let videos = videoPath.iterateChildren().compactMap{ vv -> [Path] in
                    []
                }
                
            }
        }
        
        
        
        
    }
}

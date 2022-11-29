import Quick
import Nimble
import PathKit
import CmdLib

class VLC_specs: QuickSpec {
    override func spec() {
        describe("aliplaylist") {

            beforeEach {

            }
            xit("aliPlaylist") {
                let _ = CmdLib.Ali.to(dir: "【插座学院】大神教你抖音涨粉/2一、技能篇：零基础也能制作爆款抖音（3节）")
            }
            
            xit("glob") {
                let dir = Path("/Volumes/127.0.0.1")
                let _ = dir.glob("*拆为己用").map { path in
                        print("文件路径：\(path.string)")
                    if(path.isFile){
//                        print("文件路径：\(path.string)")
                    }
                }
            }
            
            it("children") {
                let dir = Path("/Volumes/127.0.0.1")
                let _ = try! dir.recursiveChildren().map { path in
                    print("目录: \(path.string)")
                }
            }
        }
        
    }
}

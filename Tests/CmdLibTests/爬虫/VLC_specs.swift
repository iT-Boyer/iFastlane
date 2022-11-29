import Quick
import Nimble
import PathKit
import CmdLib

class VLC_specs: QuickSpec {
    override func spec() {
        describe("aliplaylist") {

            beforeEach {

            }
            it("aliPlaylist") {
                let _ = CmdLib.Ali.to(dir: "【船长精品】《 得 到 》平台专题 2016-2021.10 全部VIP课程/08 训练营/01 脱不花 30天沟通训练营")
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
            
            xit("children") {
                let dir = Path("/Volumes/127.0.0.1")
                let _ = try! dir.recursiveChildren().map { path in
                    print("目录: \(path.string)")
                }
            }
        }
        
    }
}

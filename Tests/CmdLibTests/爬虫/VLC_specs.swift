import Quick
import Nimble
import PathKit
import CmdLib

class VLC_specs: QuickSpec {
    override class func spec() {
        describe("aliplaylist") {

            beforeEach {

            }
            fit("aliPlaylist") {
                let _ = CmdLib.Ali.to(dir: "镖人 (2023)")
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

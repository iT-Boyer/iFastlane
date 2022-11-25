import Quick
import Nimble
import PathKit

class VLC_specs: QuickSpec {
    override func spec() {
        describe("aliplaylist") {

            // let ali = Path("\(Path.home)/rclone/Ali")
            let ali = Path("/Volumes/127.0.0.1/")
            let http = "http://localhost:8686/"
            let m3u = Path.home+"Desktop/管理课程.m3u8"
//            let directory = Path("极客时间/70-算法面试通关40讲")
//            let directory = Path("《黄渤》系列14部 (2006-2018)")
            let directory = Path("【06】【管理课程】35合集173G")
            let alil = ali + directory
            beforeEach {

            }
            it("aliPlaylist") {

                if alil.exists {
                    print("-----递归------")
                    guard let childrens = try? alil.recursiveChildren() else { return }
                    var content = ""
                    let times = "0"
                    let _ = childrens.map { pp in
                        let _ = (pp.glob("*mp4") + pp.glob("*MP4") + pp.glob("*mp3") + pp.glob("*mp4a") + pp.glob("*avi") + pp.glob("*wav") + pp.glob("*wma")).map{ path in
                            let m3u8 = """
                                \n#EXTINF:\(times),\(path.lastComponentWithoutExtension)
                                \(path)
                                """
                           content.append(m3u8)
                        }
                    }
                    //replacingOccurrences
                    content = content.replacingOccurrences(of: ali.string, with: http)
                    try! m3u.write(content)
                }
            }
        }
        
    }
}

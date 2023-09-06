import Cocoa
import XCTest


func queueee(cmds:[String]) {
    
    var semaphore = DispatchSemaphore(value: 3)
    let total = cmds.count
    var completed = 0
    
    var queue = DispatchQueue(label: "多线程", attributes: .concurrent)
    cmds.forEach { cmd in
        semaphore.wait()
        queue.async {
            sleep(1)
            print("\(cmd) 命令:\(Thread.current)")
            completed += 1
            semaphore.signal()
            if completed == total{
                print("下载完成")
            }
        }
    }
}

func group(cmds:[String]) {
    let manualGroup = DispatchGroup()
    //模拟循环建立几个全局队列
    for manualIndex in 0...3 {
        //进入队列管理
        manualGroup.enter()
        DispatchQueue.global().async {
            //让线程随机休息几秒钟：即在实际工作共处理大数据的地方
            Thread.sleep(forTimeInterval: TimeInterval(arc4random_uniform(2) + 1))
            print("-----手动任务\(manualIndex):\(Thread.current)执行完毕")
            //配置完队列之后，离开队列管理
            manualGroup.leave()
        }
    }
    //发送通知
    manualGroup.notify(queue: DispatchQueue.main) {
        print("手动任务组的任务都已经执行完毕啦！")
    }
}



class MyTests : XCTestCase {
    var cmds:[String]!
    override func setUp() {
        let cmds = ["echo hello", "echo hello2", "echo hello3"]
    }
    
    func testGroup() {
        group()
    }
//    func testShouldFail() {
//        XCTFail("You must fail to succeed!")
//    }
//    func testShouldPass() {
//        XCTAssertEqual(2+2, 4)
//    }
    
    override func tearDown() {
    }
}

TestRunner().runTests(testClass: MyTests.self)

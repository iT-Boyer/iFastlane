import Cocoa
import SwiftShell

var greeting = "Hello, playground"

let cmds = ["echo hello", "echo hello2", "echo hello3"]

var semaphore = DispatchSemaphore(value: 5)
let total = wmaCmds.count
var completed = 0
cmds.forEach { cmd in
    semaphore.wait()
    SwiftShell.runAsyncAndPrint(bash: cmd).onCompletion { cmd in
        completed += 1
        print("完成：\(completed)个 \(Thread.current)")
        semaphore.signal()
        if completed == total{
            print("下载完成")
        }
    }
}

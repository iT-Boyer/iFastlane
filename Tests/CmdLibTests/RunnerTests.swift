import XCTest
import class Foundation.Bundle
import Nimble
@testable import CmdLib

final class RunnerTests: XCTestCase {
    
    func test2Tools() {
        let arr1 = ["1","2","3"]
        let arr2 = ["3","4","5"]
        let arr = CmdTools().arrDiff(arr1: arr1, arr2: arr2)
        let exparr = ["1","2","5"]
        print("结果：\(arr)")
//        expect("\(arr)").to(contain("hao"))
        expect(arr).toNot(contain("4"))
        expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
    }
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        // Mac Catalyst won't have `Process`, but it is supported for executables.
        #if !targetEnvironment(macCatalyst)

        let fooBinary = productsDirectory.appendingPathComponent("Runner")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, "Hello, world!\n")
        #endif
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}

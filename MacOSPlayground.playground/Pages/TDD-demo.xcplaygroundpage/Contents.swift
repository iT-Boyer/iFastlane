//: [Previous](@previous)

import XCTest

class MyTests : XCTestCase {
    func testShouldFail() {
        XCTFail("You must fail to succeed!")
    }
    func testShouldPass() {
        XCTAssertEqual(2+2, 4)
    }
}

TestRunner().runTests(testClass: MyTests.self)

//: [Previous](@previous)

import XCTest

// Put your implementation here:



// Write your tests here:

class MyTests : XCTestCase {
    override func setUp() {
    }
    
    func testShouldFail() {
        XCTFail("You must fail to succeed!")
    }
    func testShouldPass() {
        XCTAssertEqual(2+2, 4)
    }
    
    override func tearDown() {
    }
}

TestRunner().runTests(testClass: MyTests.self)

//: [Next](@next)

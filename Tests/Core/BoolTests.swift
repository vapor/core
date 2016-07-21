import Foundation
import XCTest
@testable import Core

class BoolTests: XCTestCase {
    static var allTests = [
        ("testStringConvert", testStringConvert)
    ]

    func testStringConvert() {
        XCTAssertEqual(Bool("y"), true)
        XCTAssertEqual(Bool("yes"), true)
        XCTAssertEqual(Bool("true"), true)
        XCTAssertEqual(Bool("n"), false)
        XCTAssertEqual(Bool(""), nil)
        XCTAssertEqual(Bool("NO"), false)
        XCTAssertEqual(Bool("asdf"), nil)
        XCTAssertEqual(Bool("234234"), nil)
    }
}

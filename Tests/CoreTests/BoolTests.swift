import Foundation
import XCTest
@testable import Core

class BoolTests: XCTestCase {
    static var allTests = [
        ("testStringConvert", testStringConvert)
    ]

    func testStringConvert() {
        XCTAssertEqual(Bool(fuzzy: "y"), true)
        XCTAssertEqual(Bool(fuzzy: "yes"), true)
        XCTAssertEqual(Bool(fuzzy: "true"), true)
        XCTAssertEqual(Bool(fuzzy: "n"), false)
        XCTAssertEqual(Bool(fuzzy: ""), nil)
        XCTAssertEqual(Bool(fuzzy: "NO"), false)
        XCTAssertEqual(Bool(fuzzy: "asdf"), nil)
        XCTAssertEqual(Bool(fuzzy: "234234"), nil)
    }
}

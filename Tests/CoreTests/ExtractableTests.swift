import Foundation
import XCTest
@testable import Core

class ExtractableTests: XCTestCase {
    static var allTests = [
        ("testPresent", testPresent),
        ("testNil", testNil)
    ]

    func testPresent() {
        let string: Optional<String> = "42"

        XCTAssert(string.isNilOrEmpty == false)
        XCTAssert(string.extract() == "42")
    }

    func testNil() {
        let string: Optional<String> = nil

        XCTAssert(string.isNilOrEmpty == true)
        XCTAssert(string.extract() == nil)
    }
}

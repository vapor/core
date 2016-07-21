import Foundation
import XCTest
@testable import Core

class UtilityTests: XCTestCase {

    static var allTests = [
        ("testLowercase", testLowercase),
        ("testUppercase", testUppercase),
        ("testEquals", testEquals),
    ]

    func testLowercase() {
        let test = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()"

        XCTAssertEqual(
            test.bytes.lowercased.string,
            test.lowercased(),
            "Data utility did not match Foundation"
        )
    }

    func testUppercase() {
        let test = "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()"

        XCTAssertEqual(
            test.bytes.uppercased.string,
            test.uppercased(),
            "Data utility did not match Foundation"
        )
    }

    func testEquals() {
        XCTAssertEqual([0, 1, 2].equals(any: [0, 1, 2]), true)
        XCTAssertEqual([0, 1, 2].equals(any: [[5, 4], [0, 2, 1]]), false)
    }
}

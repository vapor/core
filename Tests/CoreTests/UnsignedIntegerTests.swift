import Foundation
import XCTest
@testable import Core
import libc

class UnsignedIntegerTests: XCTestCase {

    static let allTests = [
        ("testMask", testMask)
    ]

    func testMask() {
        let flags: UInt = 0x01 | 0x04

        XCTAssertEqual(flags.containsMask(0x04), true)
        XCTAssertEqual(flags.containsMask(0x01), true)
        XCTAssertEqual(flags.containsMask(0x02), false)
    }
}

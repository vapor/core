import Foundation
import XCTest
@testable import Core
import libc

class UnsignedIntegerTests: XCTestCase {

    static var allTests = [
        ("testMask", testMask)
    ]

    func testMask() {
        let flags = SOCK_RAW | SOCK_DGRAM

        let uint = UInt(flags)

        XCTAssertEqual(uint.containsMask(UInt(SOCK_RAW)), true)
        XCTAssertEqual(uint.containsMask(UInt(SOCK_DGRAM)), true)
        XCTAssertEqual(uint.containsMask(UInt(SOCK_MAXADDRLEN)), false)
    }
}
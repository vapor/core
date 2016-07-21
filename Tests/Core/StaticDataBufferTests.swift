import Foundation
import XCTest
@testable import Core

class StaticDataBufferTests: XCTestCase {
    static var allTests = [
        ("testNext", testNext),
        ("testNextMatchesAny", testNextMatchesAny),
        ("testNextMatches", testNextMatches),
        ("testLocalBuffer", testLocalBuffer),
    ]

    func testNext() throws {
        let buffer = StaticDataBuffer(bytes: "hello".bytes)
        XCTAssertEqual(try buffer.next(), "h".bytes.first)
    }

    func testNextMatchesAny() throws {
        let buffer = StaticDataBuffer(bytes: "h".bytes)

        guard let l = "l".bytes.first else {
            XCTFail("Could not convert l.")
            return
        }

        guard let h = "h".bytes.first else {
            XCTFail("Could not convert h.")
            return
        }

        XCTAssertEqual(try buffer.next(matchesAny: l), false)
        XCTAssertEqual(try buffer.next(matchesAny: h), true)
        _ = try buffer.next() // empty buffer
        XCTAssertEqual(try buffer.next(matchesAny: h), false)
    }

    func testNextMatches() throws {
        let buffer = StaticDataBuffer(bytes: "h".bytes)

        XCTAssertEqual(try buffer.next(matches: { byte in
            return byte == "h".bytes.first
        }), true)

        _ = try buffer.next() // empty buffer

        XCTAssertEqual(try buffer.next(matches: { byte in
            return byte == "h".bytes.first
        }), false)
    }

    func testLocalBuffer() throws {
        let buffer = StaticDataBuffer(bytes: "hi".bytes)
        buffer.returnToBuffer(.a)
        XCTAssertEqual(try buffer.next(), .a)
    }

}

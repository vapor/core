import Foundation
import XCTest
@testable import Core

class StaticDataBufferTests: XCTestCase {
    static let allTests = [
        ("testNext", testNext),
        ("testNextMatchesAny", testNextMatchesAny),
        ("testNextMatches", testNextMatches),
        ("testLocalBuffer", testLocalBuffer),
        ("testCollect", testCollect),
        ("testLeadingBuffer", testLeadingBuffer),
        ("testCollectUntil", testCollectUntil),
        ("testCollectUntilConverting", testCollectUntilConverting),
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

    func testCollect() throws {
        let buffer = StaticDataBuffer(bytes: "ferret".bytes)

        let firstThree = try buffer.collect(next: 3)
        XCTAssertEqual(firstThree, "fer".bytes)

        try buffer.discardNext(1)

        let lastTwo = try buffer.collect(next: 2)
        XCTAssertEqual(lastTwo, "et".bytes)

        let none = try buffer.collect(next: 0)
        XCTAssertEqual(none, [])

        let alsoNone = try buffer.collect(next: 1)
        XCTAssertEqual(alsoNone, [])
    }

    func testLeadingBuffer() throws {
        let buffer = StaticDataBuffer(bytes: "vapor".bytes)
        XCTAssertEqual(try buffer.checkLeadingBuffer(matches: "vap".bytes), true)
        XCTAssertEqual(try buffer.checkLeadingBuffer(matches: .a, .f), false)
    }

    func testCollectUntil() throws {
        let buffer = StaticDataBuffer(bytes: "123456789".bytes)
        let collected = try buffer.collect(until: .nine)
        XCTAssertEqual(collected, "12345678".bytes)
        XCTAssertEqual(try buffer.collectRemaining(), "9".bytes)
    }

    func testCollectUntilConverting() throws {
        let buffer = StaticDataBuffer(bytes: "123456789".bytes)
        let collected = try buffer.collect(until: .nine) { byte in
            return byte == "5".bytes.first ? .nine : byte
        }
        XCTAssertEqual(collected, "12349678".bytes)
    }
}

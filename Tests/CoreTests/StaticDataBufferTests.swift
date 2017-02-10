import Foundation
import XCTest
@testable import Core

class StaticDataBufferTests: XCTestCase {
    static var allTests = [
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
        let buffer = StaticDataBuffer(bytes: "hello".makeBytes())
        XCTAssertEqual(try buffer.next(), "h".makeBytes().first)
    }

    func testNextMatchesAny() throws {
        let buffer = StaticDataBuffer(bytes: "h".makeBytes())

        guard let l = "l".makeBytes().first else {
            XCTFail("Could not convert l.")
            return
        }

        guard let h = "h".makeBytes().first else {
            XCTFail("Could not convert h.")
            return
        }

        XCTAssertEqual(try buffer.next(matchesAny: l), false)
        XCTAssertEqual(try buffer.next(matchesAny: h), true)
        _ = try buffer.next() // empty buffer
        XCTAssertEqual(try buffer.next(matchesAny: h), false)
    }

    func testNextMatches() throws {
        let buffer = StaticDataBuffer(bytes: "h".makeBytes())

        XCTAssertEqual(try buffer.next(matches: { byte in
            return byte == "h".makeBytes().first
        }), true)

        _ = try buffer.next() // empty buffer

        XCTAssertEqual(try buffer.next(matches: { byte in
            return byte == "h".makeBytes().first
        }), false)
    }

    func testLocalBuffer() throws {
        let buffer = StaticDataBuffer(bytes: "hi".makeBytes())
        buffer.returnToBuffer(.a)
        XCTAssertEqual(try buffer.next(), .a)
    }

    func testCollect() throws {
        let buffer = StaticDataBuffer(bytes: "ferret".makeBytes())

        let firstThree = try buffer.collect(next: 3)
        XCTAssertEqual(firstThree, "fer".makeBytes())

        try buffer.discardNext(1)

        let lastTwo = try buffer.collect(next: 2)
        XCTAssertEqual(lastTwo, "et".makeBytes())

        let none = try buffer.collect(next: 0)
        XCTAssertEqual(none, [])

        let alsoNone = try buffer.collect(next: 1)
        XCTAssertEqual(alsoNone, [])
    }

    func testLeadingBuffer() throws {
        let buffer = StaticDataBuffer(bytes: "vapor".makeBytes())
        XCTAssertEqual(try buffer.checkLeadingBuffer(matches: "vap".makeBytes()), true)
        XCTAssertEqual(try buffer.checkLeadingBuffer(matches: .a, .f), false)
    }

    func testCollectUntil() throws {
        let buffer = StaticDataBuffer(bytes: "123456789".makeBytes())
        let collected = try buffer.collect(until: .nine)
        XCTAssertEqual(collected, "12345678".makeBytes())
        XCTAssertEqual(try buffer.collectRemaining(), "9".makeBytes())
    }

    func testCollectUntilConverting() throws {
        let buffer = StaticDataBuffer(bytes: "123456789".makeBytes())
        let collected = try buffer.collect(until: .nine) { byte in
            return byte == "5".makeBytes().first ? .nine : byte
        }
        XCTAssertEqual(collected, "12349678".makeBytes())
    }
}

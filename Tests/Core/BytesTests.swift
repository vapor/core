import Foundation
import XCTest
@testable import Core

class BytesTests: XCTestCase {

    static var allTests = [
        ("testStringError", testStringError),
        ("testPatternMatch", testPatternMatch),
        ("testPatternArrayMatch", testPatternArrayMatch),
        ("testBytesSlice", testBytesSlice),
        ("testEasyAppend", testEasyAppend),
        ("testIntHex", testIntHex),
        ("testHexInt", testHexInt),
        ("testTrim", testTrim),
        ("testTrimEmpty", testTrimEmpty),
        ("testTrimAll", testTrimAll)
    ]

    func testStringError() {
        // ✨ = [226, 156, 168]
        let bytes: Bytes = [226, 156]
        XCTAssertEqual(bytes.string, "")
    }

    func testPatternMatch() {
        switch [Byte.a] {
        case [Byte.a]:
            break
        default:
            XCTFail("Pattern match failed.")
        }
    }

    func testPatternArrayMatch() {
        switch Byte.a {
        case [Byte.a, Byte.f]:
            break
        default:
            XCTFail("Pattern match failed.")
        }
    }

    func testBytesSlice() {
        let slice = "hello".bytesSlice
        XCTAssertEqual(slice, ArraySlice("hello".bytes))
    }

    func testEasyAppend() {
        var bytes: Bytes = [0x00]
        bytes += 0x42

        XCTAssertEqual(bytes, [0x00, 0x42])
    }

    func testIntHex() {
        XCTAssertEqual(255.hex, "FF")
    }

    func testHexInt() {
        XCTAssertEqual("aBf89".bytes.hexInt, 704393)
    }

    func testTrim() {
        let result = Array("==hello==".characters).trimmed(["="])
        XCTAssertEqual(String(result), "hello")
    }

    func testTrimEmpty() {
        let result = Array("".characters).trimmed([])
        XCTAssertEqual(String(result), "")
    }

    func testTrimAll() {
        let result = Array("~~".characters).trimmed(["~"])
        XCTAssertEqual(String(result), "")
    }
}

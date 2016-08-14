import Foundation
import XCTest
@testable import Core

class BytesTests: XCTestCase {

    static let allTests = [
        ("testStringError", testStringError),
        ("testPatternMatch", testPatternMatch),
        ("testPatternArrayMatch", testPatternArrayMatch),
        ("testBytesSlice", testBytesSlice),
        ("testBytesSlicePatternMatching", testBytesSlicePatternMatching),
        ("testEasyAppend", testEasyAppend),
        ("testIntHex", testIntHex),
        ("testHexInt", testHexInt),
        ("testDecimalInt", testDecimalInt),
        ("testDecimalIntError", testDecimalIntError),
        ("testTrim", testTrim),
        ("testTrimEmpty", testTrimEmpty),
        ("testTrimAll", testTrimAll),
        ("testStringConvertible", testStringConvertible),
        ("testDataConvertible", testDataConvertible)
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

    func testBytesSlicePatternMatching() {
        let arr: Bytes = [1, 2, 3]
        switch arr[0...1] {
        case [3, 4]:
            XCTFail()
        case [1, 2]:
            break
        default:
            XCTFail()
        }

        switch arr[1...2] {
        case arr:
            XCTFail()
        default:
            break
        }
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

    func testDecimalInt() {
        let test = "1337"
        XCTAssertEqual(test.bytes.decimalInt, 1337)
    }

    func testDecimalIntError() {
        let test = "13ferret37"
        XCTAssertEqual(test.bytes.decimalInt, nil)
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

    func testStringConvertible() throws {
        let bytes: Bytes = [0x64, 0x65]
        let string = try String(bytes: bytes)
        XCTAssertEqual(try string.makeBytes(), bytes)
    }

    func testDataConvertible() throws {
        let bytes: Bytes = [0x64, 0x65]
        let data = Data(bytes: bytes)
        XCTAssertEqual(try data.makeBytes(), bytes)
    }
}

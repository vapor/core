import Foundation
import XCTest
@testable import Core

class ByteTests: XCTestCase {

    static let allTests = [
        ("testRandom", testRandom),
        ("testIsCases", testIsCases),
        ("testPatternMatching", testPatternMatching),
        ("testBase64", testBase64),
    ]

    func testRandom() {
        var one: Bytes = []
        var two: Bytes = []

        for _ in 0..<20 {
            one.append(Byte.random())
            two.append(Byte.random())
        }

        XCTAssert(one != two)
    }

    func testIsCases() {
        // white space
        XCTAssertEqual(" ".bytes.first?.isWhitespace, true)
        XCTAssertEqual("\n".bytes.first?.isWhitespace, true)
        XCTAssertEqual("\r".bytes.first?.isWhitespace, true)
        XCTAssertEqual("\t".bytes.first?.isWhitespace, true)
        XCTAssertEqual("=".bytes.first?.isWhitespace, false)

        // letters
        XCTAssertEqual("a".bytes.first?.isLetter, true)
        XCTAssertEqual("F".bytes.first?.isLetter, true)
        XCTAssertEqual("g".bytes.first?.isLetter, true)
        XCTAssertEqual("é".bytes.first?.isLetter, false)

        // digits
        for i in 0...9 {
            XCTAssertEqual(i.description.bytes.first?.isDigit, true)
            XCTAssertEqual(i.description.bytes.first?.isAlphanumeric, true)
        }
        XCTAssertEqual("f".bytes.first?.isDigit, false)

        // hex digits
        for character in "0123456789abcdefABCDEF".characters {
            XCTAssertEqual(String(character).bytes.first?.isHexDigit, true)
        }
        XCTAssertEqual("g".bytes.first?.isHexDigit, false)
    }

    func testPatternMatching() {
        switch Byte.a {
        case Byte.f:
            XCTFail()
        case Byte.a:
            break
        default:
            XCTFail()
        }
    }

    func testBase64() {
        XCTAssertEqual("dmFwb3I=".base64DecodedString, "vapor")
        XCTAssertEqual("⚠️".base64DecodedString, "")
        XCTAssertEqual("hello".bytes.base64String, "aGVsbG8=")
        XCTAssertEqual("hello".bytes.base64Data, "aGVsbG8=".bytes)
    }
}

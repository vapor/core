import Foundation
import XCTest
@testable import Core

class ByteTests: XCTestCase {

    static var allTests = [
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

    public func testIsCases() {
        // white space
        XCTAssertEqual(" ".makeBytes().first?.isWhitespace, true)
        XCTAssertEqual("\n".makeBytes().first?.isWhitespace, true)
        XCTAssertEqual("\r".makeBytes().first?.isWhitespace, true)
        XCTAssertEqual("\t".makeBytes().first?.isWhitespace, true)
        XCTAssertEqual("=".makeBytes().first?.isWhitespace, false)

        // letters
        XCTAssertEqual("a".makeBytes().first?.isLetter, true)
        XCTAssertEqual("F".makeBytes().first?.isLetter, true)
        XCTAssertEqual("g".makeBytes().first?.isLetter, true)
        XCTAssertEqual("é".makeBytes().first?.isLetter, false)

        // digits
        for i in 0...9 {
            XCTAssertEqual(i.description.makeBytes().first?.isDigit, true)
            XCTAssertEqual(i.description.makeBytes().first?.isAlphanumeric, true)
        }
        XCTAssertEqual("f".makeBytes().first?.isDigit, false)

        // hex digits
        for character in "0123456789abcdefABCDEF".characters {
            XCTAssertEqual(String(character).makeBytes().first?.isHexDigit, true)
        }
        XCTAssertEqual("g".makeBytes().first?.isHexDigit, false)
    }

    public func testPatternMatching() {
        switch Byte.a {
        case Byte.f:
            XCTFail()
        case Byte.a:
            break
        default:
            XCTFail()
        }
    }

    public func testBase64() {
        XCTAssertEqual("dmFwb3I=".base64DecodedString, "vapor")
        XCTAssertEqual("⚠️".base64DecodedString, "")
        XCTAssertEqual("hello".makeBytes().base64String, "aGVsbG8=")
        XCTAssertEqual("hello".makeBytes().base64Data, "aGVsbG8=".makeBytes())
    }
}

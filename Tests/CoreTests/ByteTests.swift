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

    private let base64Dec = "Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott Hello こんにちは 你好 안녕하세요 Здравствуйте! Grüß Gott"

    private let base64Enc = "SGVsbG8g44GT44KT44Gr44Gh44GvIOS9oOWlvSDslYjrhZXtlZjshLjsmpQg0JfQtNGA0LDQstGB0YLQstGD0LnRgtC1ISBHcsO8w58gR290dCBIZWxsbyDjgZPjgpPjgavjgaHjga8g5L2g5aW9IOyViOuFle2VmOyEuOyalCDQl9C00YDQsNCy0YHRgtCy0YPQudGC0LUhIEdyw7zDnyBHb3R0IEhlbGxvIOOBk+OCk+OBq+OBoeOBryDkvaDlpb0g7JWI64WV7ZWY7IS47JqUINCX0LTRgNCw0LLRgdGC0LLRg9C50YLQtSEgR3LDvMOfIEdvdHQgSGVsbG8g44GT44KT44Gr44Gh44GvIOS9oOWlvSDslYjrhZXtlZjshLjsmpQg0JfQtNGA0LDQstGB0YLQstGD0LnRgtC1ISBHcsO8w58gR290dCBIZWxsbyDjgZPjgpPjgavjgaHjga8g5L2g5aW9IOyViOuFle2VmOyEuOyalCDQl9C00YDQsNCy0YHRgtCy0YPQudGC0LUhIEdyw7zDnyBHb3R0IEhlbGxvIOOBk+OCk+OBq+OBoeOBryDkvaDlpb0g7JWI64WV7ZWY7IS47JqUINCX0LTRgNCw0LLRgdGC0LLRg9C50YLQtSEgR3LDvMOfIEdvdHQgSGVsbG8g44GT44KT44Gr44Gh44GvIOS9oOWlvSDslYjrhZXtlZjshLjsmpQg0JfQtNGA0LDQstGB0YLQstGD0LnRgtC1ISBHcsO8w58gR290dCBIZWxsbyDjgZPjgpPjgavjgaHjga8g5L2g5aW9IOyViOuFle2VmOyEuOyalCDQl9C00YDQsNCy0YHRgtCy0YPQudGC0LUhIEdyw7zDnyBHb3R0IEhlbGxvIOOBk+OCk+OBq+OBoeOBryDkvaDlpb0g7JWI64WV7ZWY7IS47JqUINCX0LTRgNCw0LLRgdGC0LLRg9C50YLQtSEgR3LDvMOfIEdvdHQgSGVsbG8g44GT44KT44Gr44Gh44GvIOS9oOWlvSDslYjrhZXtlZjshLjsmpQg0JfQtNGA0LDQstGB0YLQstGD0LnRgtC1ISBHcsO8w58gR290dA=="
    
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
        for _ in 0..<1000 {
            XCTAssertEqual("dmFwb3I=".bytes.base64Decoded.string, "vapor")
            XCTAssertEqual("⚠️".bytes.base64Decoded.string, "")
            XCTAssertEqual("hello".bytes.base64Encoded.string, "aGVsbG8=")
            XCTAssertEqual("hello".bytes.base64Encoded, "aGVsbG8=".bytes)
            XCTAssertEqual(base64Dec.bytes.base64Encoded, base64Enc.bytes)
            XCTAssertEqual(base64Enc.bytes.base64Decoded, base64Dec.bytes)
        }
    }
}

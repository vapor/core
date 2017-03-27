import XCTest
@testable import Core

class PolymorphicTests: XCTestCase {
    static let allTests = [
        ("testInt", testInt),
        ("testUInt", testUInt),
        ("testArray", testArray),
        ("testFloat", testFloat),
        ("testDouble", testDouble),
        ("testNull", testNull),
        ("testBool", testBool),
        ("testBytes", testBytes),
    ]

    func testInt() {
        let poly = "-123"
        XCTAssert(poly.int == -123)
        XCTAssert(poly.uint == nil)
        XCTAssert(poly.string == "-123")
    }

    func testUInt() {
        let poly = UInt.max.description
        XCTAssert(poly.uint == UInt.max)
        XCTAssert(poly.int == nil)
    }

    func testArray() {
        let list = "oranges, apples , bananas, grapes"
        let fruits = list.commaSeparatedArray()
        XCTAssert(fruits == ["oranges", "apples", "bananas", "grapes"])
    }

    func testFloat() {
        let poly = "3.14159"
        XCTAssert(poly.float == 3.14159)
    }

    func testDouble() {
        let poly = "999999.999"
        XCTAssert(poly.double == 999_999.999)
    }

    func testNull() {
        XCTAssert("null".isNull == true)
        XCTAssert("NULL".isNull == true)
    }

    func testBool() {
        XCTAssert("y".bool == true)
        XCTAssert("yes".bool == true)
        XCTAssert("t".bool == true)
        XCTAssert("true".bool == true)
        XCTAssert("1".bool == true)
        XCTAssert("on".bool == true)


        XCTAssert("n".bool == false)
        XCTAssert("no".bool == false)
        XCTAssert("f".bool == false)
        XCTAssert("false".bool == false)
        XCTAssert("0".bool == false)
        XCTAssert("off".bool == false)

        XCTAssert("nothing".bool == nil)
        XCTAssert("to".bool == nil)
        XCTAssert("see".bool == nil)
        XCTAssert("here".bool == nil)
    }

    func testBytes() {
        let expectation = [0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x20, 0xF0, 0x9F, 0x91, 0x8B] as [UInt8]
        let input = "Hello, World 👋".bytes
        XCTAssertEqual(expectation, input)
    }
}

import Bits
import Core
import Foundation
import XCTest


class UtilityTests: XCTestCase {
    static var allTests = [
        ("testLowercase", testLowercase),
        ("testUppercase", testUppercase),
        ("testIntHex", testIntHex),
        ("testWorkDir", testWorkDir)
    ]

    func testLowercase() {
        let test = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()"

        XCTAssertEqual(
            test.makeBytes().lowercased.makeString(),
            test.lowercased(),
            "Data utility did not match Foundation"
        )
    }

    func testUppercase() {
        let test = "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()"

        XCTAssertEqual(
            test.makeBytes().uppercased.makeString(),
            test.uppercased(),
            "Data utility did not match Foundation"
        )
    }

    func testIntHex() {
        let signedHex = (-255).hex
        XCTAssertEqual(signedHex, "-FF")

        let unsignedHex = Byte(125).hex
        XCTAssertEqual(unsignedHex, "7D")
    }

    func testWorkDir() {
        let workDir = workingDirectory()
        XCTAssertNotEqual(workDir, "")
    }
}

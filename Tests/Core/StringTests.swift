import Foundation
import XCTest
@testable import Core

class StringTests: XCTestCase {

    static var allTests = [
        ("testStringCaseInsensitiveCompare", testStringCaseInsensitiveCompare),
        ("testStringFinished", testStringFinished),
    ]

    func testStringCaseInsensitiveCompare() {
        XCTAssert("ferret".equals(caseInsensitive: "FeRrEt"))
    }

    func testStringFinished() {
        XCTAssertEqual("www.google.com".finished(with: "/"), "www.google.com/")
        XCTAssertEqual("www.google.com/".finished(with: "/"), "www.google.com/")
    }
}

import Foundation
import XCTest
@testable import Core

class ISO8601Tests: XCTestCase {

    static var allTests = [
        ("testBasic", testBasic)
    ]

    func testBasic() {
        let date = Date(iso8601: "2016-06-18T05:18:27.935Z")
        XCTAssertEqual(date?.iso8601, "2016-06-18T05:18:27.935Z")
    }

    func testFail() {
        let date = Date(iso8601: "Ferret")
        XCTAssertNil(date)
    }
}

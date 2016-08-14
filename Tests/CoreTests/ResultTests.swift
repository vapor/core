import Foundation
import XCTest
@testable import Core

private enum TestError: Error {
    case test
}

class ResultTests: XCTestCase {
    static let allTests = [
        ("testValue", testValue),
        ("testValueNil", testValueNil),
    ]

    func testValue() {
        let result = Result.success(1)
        XCTAssertEqual(result.value, 1)
        XCTAssert(result.error == nil)
        XCTAssertEqual(result.succeeded, true)
    }

    func testValueNil() {
        let result = Result<Int>.failure(TestError.test)
        XCTAssertEqual(result.value, nil)
        XCTAssert(result.error != nil)
        XCTAssertEqual(result.succeeded, false)
    }
}

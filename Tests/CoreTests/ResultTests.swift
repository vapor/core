import Foundation
import XCTest
@testable import Core

class ResultTests: XCTestCase {
    private enum TestError: Error {
        case test
    }

    static var allTests = [
        ("testValue", testValue),
        ("testValueNil", testValueNil),
    ]

    func testValue() {
        let result = Result.success(1)
        XCTAssertEqual(result.value, 1)
        XCTAssert(result.error == nil)
        XCTAssertEqual(result.succeeded, true)
        XCTAssertEqual(result.isSuccess, true)
        XCTAssertEqual(result.isFailure, false)
    }

    func testValueNil() {
        let result = Result<Int>.failure(TestError.test)
        XCTAssertEqual(result.value, nil)
        XCTAssert(result.error != nil)
        XCTAssertEqual(result.succeeded, false)
        XCTAssertEqual(result.isSuccess, false)
        XCTAssertEqual(result.isFailure, true)
    }
}

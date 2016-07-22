import Foundation
import XCTest
@testable import Core

class ArrayTests: XCTestCase {
    static var allTests = [
        ("testChunked", testChunked),
        ("testSafeAccess", testSafeAccess),
    ]

    func testChunked() {
        let result = [1, 2, 3, 4, 5].chunked(size: 2)

        guard result.count == 3 else {
            XCTFail("Invalid count")
            return
        }

        XCTAssertEqual(result[0], [1, 2])
        XCTAssertEqual(result[1], [3, 4])
        XCTAssertEqual(result[2], [5])
    }

    func testSafeAccess() {
        let array = [1, 2, 3]

        XCTAssertEqual(array[safe: 4], nil)
        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: -1], nil)
    }
}

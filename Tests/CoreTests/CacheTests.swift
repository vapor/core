import Bits
import Foundation
import XCTest
@testable import Core

extension String: Cacheable {
    public func cacheSize() -> Size {
        return utf8.count
    }
}

class CacheTests: XCTestCase {
    static let allTests = [
        ("testCacheDrops", testCacheDrops),
    ]

    func testCacheDrops() {
        let a = Bytes(repeating: .a, count: 75).makeString()
        let b = Bytes(repeating: .b, count: 25).makeString()
        let c = Bytes(repeating: .c, count: 5).makeString()

        let cache = SystemCache<String>(maxSize: 100)

        cache["a"] = a
        XCTAssertNotNil(cache["a"])
        XCTAssertNil(cache["b"])
        XCTAssertNil(cache["c"])

        cache["b"] = b
        XCTAssertNotNil(cache["a"])
        XCTAssertNotNil(cache["b"])
        XCTAssertNil(cache["c"])

        cache["c"] = c
        XCTAssertNil(cache["a"])
        XCTAssertNotNil(cache["b"])
        XCTAssertNotNil(cache["c"])
    }
}

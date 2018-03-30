@testable import Async
import XCTest

final class AsyncTests: XCTestCase {
    let worker: Worker = EmbeddedEventLoop()
    func testVariadicMap() throws {
        let futureA = Future.map(on: worker) { "a" }
        let futureB = Future.map(on: worker) { "b" }
        let futureAB = map(to: String.self, futureA, futureB) { a, b in
            return "\(a)\(b)"
        }
        try XCTAssertEqual(futureAB.wait(), "ab")
    }
    
    static let allTests = [
        ("testVariadicMap", testVariadicMap),
    ]
}

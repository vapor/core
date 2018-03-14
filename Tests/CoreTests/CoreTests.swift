import Core
import XCTest

class CoreTests: XCTestCase {
    func testProcessExecute() throws {
        try XCTAssertEqual(Process.execute("echo", "hi"), "hi")
    }

    static let allTests = [
        ("testProcessExecute", testProcessExecute),
    ]
}

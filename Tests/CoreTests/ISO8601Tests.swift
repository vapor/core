import Foundation
import XCTest
@testable import Core

class ISO8601Tests: XCTestCase {
	
	static var allTests = [
		("testBasic", testBasic)
	]
	
	func testBasic() {
		let date = Date(iso8601: "2016-07-01T04:00:00.000Z")
		XCTAssertEqual(date?.iso8601, "2016-07-01T04:00:00.000Z")
	}
	
	func testFail() {
		let date = Date(iso8601: "Ferret")
		XCTAssertNil(date)
	}
}

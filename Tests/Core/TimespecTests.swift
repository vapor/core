import Foundation
import XCTest
import libc
@testable import Core

class TimespecTests: XCTestCase {
    static let allTests = [
        ("testSecondsFromNow", testSecondsFromNow),
        ("testDoubleToTimespec", testDoubleToTimespec)
    ]

    func testSecondsFromNow() {
        let now = timespec.now
        let future = timespec(secondsFromNow: 20)
        XCTAssert((future.tv_sec - now.tv_sec) == 20)
    }

    func testDoubleToTimespec() {
        let testCases: [Double: timespec] = [
            8.092: timespec(tv_sec: 8, tv_nsec: 092_000_000),
            3.24: timespec(tv_sec: 3, tv_nsec: 240_000_000),
            7_899.892_736_13: timespec(tv_sec: 7_899, tv_nsec: 892_736_130),
            999_999.123_456_789_088: timespec(tv_sec: 999_999, tv_nsec: 123_456_789),
            888_264: timespec(tv_sec: 888_264, tv_nsec: 0)
        ]

        testCases.forEach { timestamp, timespec in
            // timestamp => timespec
            let got = timestamp.makeTimespec()
            XCTAssert(got.tv_sec == timespec.tv_sec)
            XCTAssert(got.tv_nsec == timespec.tv_nsec)

            // timespec => timestamp (using strings for fuzzier comparison)
            XCTAssert(timestamp.description == timespec.timestamp.description, "got: \(timespec.timestamp.description), expectation: \(timestamp.description)")
        }
    }
}

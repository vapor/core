import Foundation
import XCTest
import libc
@testable import Core

class TimespecTests: XCTestCase {
    static let allTests = [
        ("testSecondsFromNow", testSecondsFromNow),
        ("testDoubleToTimespec", testDoubleToTimespec),
        ("testIntToNanoseconds", testIntToNanoseconds)
    ]

    func testSecondsFromNow() {
        let now = timespec.now
        let future = timespec(secondsFromNow: 20)
        XCTAssert((future.tv_sec - now.tv_sec) == 20)
    }

    func testDoubleToTimespec() {
        let testCases: [Double: timespec] = [
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
            XCTAssert(timestamp.description == timespec.timestamp.description)
        }
    }

    func testIntToNanoseconds() {
        let cases: [Int: Int] = [
            0: 0,
            4: 400_000_000,
            21: 210_000_000,
            538: 538_000_000,
            7_231: 723_100_000,
            91_632: 916_320_000,
            619_244: 619_244_000,
            3_881_773: 388_177_300,
            12_782_919: 127_829_190,
            636_444_121: 636_444_121,
            1_234_567_893: 123_456_789, // above a billion is cut
        ]

        cases.forEach { input, expectation in
            let got = input.makeNanoseconds()
            XCTAssert(got == expectation, "got: \(got) expected: \(expectation)")
        }
    }
}

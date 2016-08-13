import Foundation
import XCTest
import libc
@testable import Core

class SemaphoreTests: XCTestCase {
    static let allTests = [
        ("testSemaphore", testSemaphore),
        ("testSemaphoreTimeout", testSemaphoreTimeout)
    ]

    func testSemaphore() throws {
        var collection = [String]()
        let semaphore = Semaphore()

        collection.append("a")
        try Core.background {
            collection.append("b")
            sleep(1) // seconds
            collection.append("c")
            semaphore.signal()
        }
        collection.append("e")
        _ = semaphore.wait(timeout: 30)
        collection.append("f")

        let expectation = ["a", "e", "b", "c", "f"]
        XCTAssert(collection == expectation, "got: \(collection), expected: \(expectation)")
    }

    func testSemaphoreTimeout() throws {
        try (1...3).forEach { timeoutTest in
            let semaphore = Semaphore()
            try background {
                let sleeptime = timeoutTest * 2
                sleep(UInt32(sleeptime))
                semaphore.signal()
            }
            let result = semaphore.wait(timeout: Double(timeoutTest))
            XCTAssert(result == .timedOut)
        }

        try (1...3).forEach { timeoutTest in
            let semaphore = Semaphore()
            try background {
                let microseconds = timeoutTest * 1_000_000
                let usleeptime = UInt32(microseconds) + 1 // 1 microsecond of variance for timeout
                usleep(usleeptime) // usleep is microseconds
                semaphore.signal()
            }
            let result = semaphore.wait(timeout: Double(timeoutTest))
            XCTAssert(result == .timedOut)
        }
    }
 }

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

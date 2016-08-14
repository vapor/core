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
                let microseconds = timeoutTest * 1_000_000
                // 1000 microsecond of variance for timeout
                let usleeptime = UInt32(microseconds) + 1000
                usleep(usleeptime) // usleep is microseconds
                semaphore.signal()
            }
            let result = semaphore.wait(timeout: Double(timeoutTest))
            XCTAssert(result == .timedOut)
        }
    }
}

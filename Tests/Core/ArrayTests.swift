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
            print("MADE IT TO BACKGROUND: \(collection)")
            collection.append("b")
            print(collection)
            sleep(1)
            print(collection)
            collection.append("c")
            print(collection)
            semaphore.signal()
        }
        collection.append("e")
        print("ENABLING SEMAPHORE")
        let result = semaphore.wait(timeout: 999_999.999)
        print("SEMAPHORE RESULT: \(result)")
        collection.append("f")

        print("**** I RAN ****")
        let expectation = ["a", "e", "b", "c", "f"]
        XCTAssert(collection == expectation, "got: \(collection), expected: \(expectation)")
    }

    func testSemaphoreTimeout() throws {
        try (1...3).forEach { timeoutTest in
            let semaphore = Semaphore()
            print("¶¶1")
            try background {
                print("¶¶2")
                let sleeptime = timeoutTest * 2
                print("¶¶3 \(sleeptime)")
                sleep(UInt32(sleeptime))
                print("¶¶4")
                semaphore.signal()
                print("¶¶5")
            }
            print("¶¶6")
            let result = semaphore.wait(timeout: Double(timeoutTest))
            print("¶¶7 \(result)")
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

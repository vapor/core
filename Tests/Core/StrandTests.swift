import libc
import Foundation
import XCTest
import Core

class StrandTests: XCTestCase {
    static let allTests = [
        ("testStrand", testStrand),
        ("testCancel", testCancel),
        ("testJoin", testJoin),
        ("testDetachFail", testDetachFail),
        ("testJoinFail", testJoinFail),
        ("testCancelFail", testCancelFail),
        ("testCreateFail", testCreateFail),
        ]

    func testStrand() throws {
        try (1...10).forEach { _ in
            var collection = [Int]()

            collection.append(0)
            _ = try Strand {
                sleep(1)
                collection.append(1)
                XCTAssert(collection == [0, 2, 1], "got [0]")
            }

            collection.append(2)
            XCTAssert(collection == [0, 2])
        }
    }

    func testCancel() throws {
        var collection = [0]

        let strand = try Strand {
            sleep(1)
            collection.append(1)
            sleep(3)
            collection.append(2)
            XCTFail("Should have cancelled")
        }

        sleep(3)
        try strand.cancel()
        XCTAssert(collection == [0, 1])
    }

    func testJoin() throws {
        var collection = [Int]()

        collection.append(0)
        let strand = try Strand {
            sleep(1)
            collection.append(1)
            XCTAssert(collection == [0, 3, 1])
            sleep(1)
            collection.append(2)
            XCTAssert(collection == [0, 3, 1, 2])
            Strand.exit(code: 0)
        }

        collection.append(3)
        XCTAssert(collection == [0, 3])

        try strand.join()
        collection.append(4)
        XCTAssert(collection == [0, 3, 1, 2, 4])
    }

    func testDetachFail() throws {
        let strand = try Strand { sleep(1) }
        try strand.detach()
        do {
            try strand.detach()
            XCTFail("detaching already detached thread should fail")
        } catch StrandError.detachFailed {}
    }

    func testJoinFail() throws {
        let strand = try Strand { sleep(1) }
        try strand.detach()
        do {
            try strand.join()
            XCTFail("join detached thread should fail")
        } catch StrandError.joinFailed {}
    }

    func testCancelFail() throws {
        let strand = try Strand {
            Strand.exit(code: 0)
        }
        try strand.detach()
        do {
            try strand.cancel()
            XCTFail("cancel detached thread should fail")
        } catch StrandError.cancellationFailed {}
    }

    func testCreateFail() throws {
        var strands: [Strand] = []
        defer {
            try! strands.forEach { strand in
                try strand.cancel()
            }
        }

        do {
            try (1...9_999).forEach { _ in
                let strand = try Strand {
                    sleep(1)
                }
                strands.append(strand)
            }
            XCTFail("create should fail at least once, too many")
        } catch StrandError.creationFailed {}
    }
}

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
        // Not a perfect test, but close enough ...
        try (1...5).forEach { _ in
            var ran = false
            let t = try Strand {
                sleep(1)
                ran = true
            }
            XCTAssertFalse(ran)
            try t.join()
            XCTAssertTrue(ran)
        }
    }

    func asdf() throws {
        try (1...3).forEach { _ in
            var collection = [Int]()
            print("0: \(collection)")
            collection.append(0)
            print("1: \(collection)")
            _ = try Strand {
                print("2: \(collection)")
                // sleep(1)
                usleep(500)
                print("3: \(collection)")
                collection.append(1)
                print("4: \(collection)")
                XCTAssert(collection == [0, 2, 1], "got \(collection)")
            }
            print("5: \(collection)")
            collection.append(2)
            print("6: \(collection)")
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

        sleep(4)
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
            sleep(1)
            try strand.cancel()
            XCTFail("cancel detached thread should fail")
        } catch StrandError.cancellationFailed {}
    }

    func testCreateFail() throws {
        var strands: [Strand] = []
        defer {
            strands.forEach { strand in
                do {
                    try strand.cancel()
                } catch {}
            }
        }

        do {
            try (1...99_999).forEach { _ in
                let strand = try Strand {
                    sleep(1)
                }
                strands.append(strand)
            }
            XCTFail("create should fail at least once, too many")
        } catch StrandError.creationFailed {}
    }
}

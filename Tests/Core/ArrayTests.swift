import Foundation
import XCTest
@testable import Core

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


import libc

class StrandTests: XCTestCase {
    static let allTests = [
        ("testCancel", testCancel),
        ("testStrand", testStrand),
        ("testJoin", testJoin)
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
}

private class StrandClosure {
    let closure: () -> Void

    init(_ closure: () -> Void) {
        self.closure = closure
    }
}

public enum StrandError: Error {
    case threadCreationFailed
    case threadCancellationFailed(Int)
    case threadJoinFailed(Int)
}

public class Strand {

    private var pthread: pthread_t

    public init(_ closure: () -> Void) throws {
        let holder = Unmanaged.passRetained(StrandClosure(closure))
        let closurePointer = UnsafeMutablePointer<Void>(holder.toOpaque())

        #if os(Linux)
            var thread: pthread_t = 0
        #else
            var thread: pthread_t?
        #endif

        let result = pthread_create(&thread, nil, runner, closurePointer)
        // back to optional so works either way (linux vs macos).
        let inner: pthread_t? = thread

        guard result == 0, let value = inner else {
            holder.release()
            throw StrandError.threadCreationFailed
        }
        pthread = value
    }

    deinit {
        pthread_detach(pthread)
    }

    public func join() throws {
        let status = pthread_join(pthread, nil)
        guard status == 0 else { throw StrandError.threadJoinFailed(Int(status)) }
    }

    public func cancel() throws {
        let status = pthread_cancel(pthread)
        guard status == 0 else { throw StrandError.threadCancellationFailed(Int(status)) }
    }

    public class func exit(code: Int) {
        var code = code
        pthread_exit(&code)
    }
}

//#if os(Linux)
    private func runner(arg: UnsafeMutablePointer<Void>?) -> UnsafeMutablePointer<Void>? {
        guard let arg = arg else { return nil }
        let unmanaged = Unmanaged<StrandClosure>.fromOpaque(arg)
        unmanaged.takeUnretainedValue().closure()
        unmanaged.release()
        return nil
    }
//#else
    private func runner(arg: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void>? {
        let unmanaged = Unmanaged<StrandClosure>.fromOpaque(arg)
        unmanaged.takeUnretainedValue().closure()
        unmanaged.release()
        return nil
    }
//#endif

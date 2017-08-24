import Core
import Dispatch
import XCTest
import libc

final class FutureTests : XCTestCase {
    func testSimpleFuture() throws {
        let promise = Promise(String.self)
        promise.complete("test")
        XCTAssertEqual(try promise.future.sync(), "test")
    }
    
    func testFutureThen() throws {
        let promise = Promise(String.self)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            promise.complete("test")
        }

        let group = DispatchGroup()
        group.enter()

        promise.future.then { result in
            XCTAssertEqual(result, "test")
            group.leave()
        }.catch { error in
            XCTFail("\(error)")
        }
        
        group.wait()
        XCTAssert(promise.future.isCompleted)
    }
    
    func testTimeoutFuture() throws {
        let promise = Promise(String.self)

        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            promise.complete("test")
        }
        
        XCTAssertFalse(promise.future.isCompleted)
        XCTAssertThrowsError(try promise.future.sync(timeout: .seconds(1)))
    }
    
    func testErrorFuture() throws {
        let promise = Promise(String.self)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            promise.fail(CustomError())
        }

        var executed = 0
        var caught = false

        let group = DispatchGroup()
        group.enter()
        promise.future.then { _ in
            XCTFail()
            executed += 1
        }.catch { error in
            executed += 1
            caught = true
            group.leave()
            XCTAssert(error is CustomError)
        }
        
        group.wait()
        XCTAssert(caught)
        XCTAssertTrue(promise.future.isCompleted)
        XCTAssertEqual(executed, 1)
    }

    func testArrayFuture() throws {
        let promiseA = Promise(String.self)
        let promiseB = Promise(String.self)

        let futures = [promiseA.future, promiseB.future]

        let group = DispatchGroup()
        group.enter()
        futures.flatten().then { array in
            XCTAssertEqual(array, ["a", "b"])
            group.leave()
        }.catch { error in
            XCTFail("\(error)")
        }

        promiseA.complete("a")
        promiseB.complete("b")

        group.wait()
    }

    func testFutureMap() throws {
        let intPromise = Promise(Int.self)

        let group = DispatchGroup()
        group.enter()

        intPromise.future.map { int in
            return String(int)
        }.then { string in
            XCTAssertEqual(string, "42")
            group.leave()
        }.catch { error in
            XCTFail("\(error)")
            group.leave()
        }

        intPromise.complete(42)
        group.wait()
    }

    func testPerformance() {
        self.measure {
            let promises = [Promise<String>](
                repeating: Promise(String.self),
                count: 4096
            )

            promises.forEach { $0.complete("hello!") }

            let group = DispatchGroup()
            promises.forEach { promise in
                group.enter()
                promise.future.then { string in
                    XCTAssertEqual(string, "hello!")
                }.catch { error in
                    XCTFail("\(error)")
                }.always {
                    group.leave()
                }
            }

            group.wait()
        }
    }

    static let allTests = [
        ("testSimpleFuture", testSimpleFuture),
        ("testFutureThen", testFutureThen),
        ("testTimeoutFuture", testTimeoutFuture),
        ("testErrorFuture", testErrorFuture),
        ("testArrayFuture", testArrayFuture),
        ("testFutureMap", testFutureMap),
        ("testPerformance", testPerformance),
    ]
}

struct CustomError : Error {}

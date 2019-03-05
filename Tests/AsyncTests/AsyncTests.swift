@testable import Async
import XCTest

final class AsyncTests: XCTestCase {
    let worker: Worker = EmbeddedEventLoop()
    func testVariadicMap() throws {
        let futureA = Future.map(on: worker) { "a" }
        let futureB = Future.map(on: worker) { "b" }
        let futureAB = map(to: String.self, futureA, futureB) { a, b in
            return "\(a)\(b)"
        }
        try XCTAssertEqual(futureAB.wait(), "ab")
    }

    func testFlatten() throws {
        let loop = EmbeddedEventLoop()
        let a = loop.newPromise(String.self)
        let b = loop.newPromise(String.self)
        let arr: [Future<String>] = [a.futureResult, b.futureResult]
        let flat = arr.flatten(on: loop)
        a.succeed(result: "a")
        b.succeed(result: "b")
        try XCTAssertEqual(flat.wait(), ["a", "b"])
    }
    
    func testSyncFlatten() throws {
        let loop = EmbeddedEventLoop()
        var lazyFutures = [LazyFuture<Int>]()
        let n = 10
        
        var completedOrder = [Int]()
        let completionQueue = DispatchQueue(label: "testSyncFlattenQueue")
        
        for i in 0..<n {
            lazyFutures.append({
                let promise = loop.newPromise(Int.self)
                // delay promises so that each promise completes faster than the one before it
                let delay = TimeInterval(Double((n - i)) / 100)
                completionQueue.asyncAfter(deadline: .now() + delay) {
                    promise.succeed(result: i)
                    completedOrder.append(i)
                }
                return promise.futureResult
            })
        }
        
        let future = lazyFutures.syncFlatten(on: loop)
        let results = try future.wait()
        
        XCTAssertTrue(results.count == n)
        XCTAssertEqual(completedOrder, results)
        
        for (lhs, rhs) in results.enumerated() {
            XCTAssertEqual(lhs, rhs)
        }
    }

    func testFlattenStackOverflow() throws {
        let loop = EmbeddedEventLoop()
        var arr: [Future<Int>] = []
        let count = 1<<12
        for i in 0..<count {
            arr.append(loop.newSucceededFuture(result: i))
        }
        try XCTAssertEqual(arr.flatten(on: loop).wait().count, count)
    }

    func testFlattenFail() throws {
        let loop = EmbeddedEventLoop()
        let a = loop.newPromise(String.self)
        let b = loop.newPromise(String.self)
        let arr: [Future<String>] = [a.futureResult, b.futureResult]
        a.succeed(result: "a")
        b.fail(error: "b")
        XCTAssertThrowsError(try arr.flatten(on: loop).wait()) { XCTAssert($0 is String) }
    }

    func testFlattenEmpty() throws {
        let loop = EmbeddedEventLoop()
        let arr: [Future<String>] = []
        try XCTAssertEqual(arr.flatten(on: loop).wait().count, 0)
    }
    
    static let allTests = [
        ("testVariadicMap", testVariadicMap),
        ("testFlatten", testFlatten),
        ("testSyncFlatten", testSyncFlatten),
        ("testFlattenStackOverflow", testFlattenStackOverflow),
        ("testFlattenFail", testFlattenFail),
        ("testFlattenEmpty", testFlattenEmpty),
    ]
}

extension String: Error { }

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
        let c = loop.newPromise(String.self)
        let arr: [Future<String>] = [a.futureResult, b.futureResult, c.futureResult]
        let flat = arr.flatten(on: loop)
        b.succeed(result: "b")
        a.succeed(result: "a")
        c.succeed(result: "c")
        try XCTAssertEqual(flat.wait(), ["a", "b", "c"])
    }
    
    func testFlattenStress() throws {
        let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        for _ in 1...20 {
            let futureCount = 5000 * System.coreCount
            var promises = [EventLoopPromise<Void>]()
            for _ in 0..<futureCount {
                promises.append(loopGroup.next().newPromise(of: Void.self))
            }
            let futures = promises.map { $0.futureResult }
            let flattener = loopGroup.next()
            
            let sema = DispatchSemaphore(value: 0)
            
            var allCompleted = false
            
            futures.flatten(on: flattener).whenSuccess { _ in
                XCTAssert(allCompleted, "This shouldn't be called as long as all futures haven't been fullfiled")
                sema.signal()
            }
            
            for promise in promises.dropLast() {
                promise.succeed()
            }
            
            allCompleted = true
            promises.last?.succeed()
            
            
            
            sema.wait()
            
            
            
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
        ("testFlattenStackOverflow", testFlattenStackOverflow),
        ("testFlattenFail", testFlattenFail),
        ("testFlattenEmpty", testFlattenEmpty),
    ]
}

extension String: Error { }

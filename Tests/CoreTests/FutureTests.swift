import XCTest
@testable import Core

final class FutureTests : XCTestCase {
    func testSimpleFuture() throws {
        let future = Future { "test" }
        
        XCTAssertEqual(try future.await(), "test")
    }
    
    func testFutureThen() throws {
        let future = Future<String> {
            usleep(5000)
            return "test"
        }
        
        future.then { result in
            XCTAssertEqual(result, "test")
        }
        
        future.catch { _ in
            XCTFail()
        }
        
        sleep(1)
        XCTAssert(future.isCompleted)
    }
    
    func testTimeoutFuture() throws {
        let future = Future<String> {
            sleep(3)
            return "test"
        }
        
        XCTAssertFalse(future.isCompleted)
        XCTAssertThrowsError(try future.await(for: .seconds(1)))
    }
    
    func testErrorFuture() throws {
        let future = Future<String> {
            usleep(500)
            throw CustomError()
        }
        
        var executed = 0
        
        future.then { _ in
            XCTFail()
        }
        
        future.catch { error in
            executed += 1
            XCTAssert(error is CustomError)
        }
        
        var caught = false
        
        future.catch(CustomError.self) { _ in
            executed += 1
            caught = true
        }
        
        sleep(4)
        XCTAssert(caught)
        XCTAssertTrue(future.isCompleted)
        XCTAssertEqual(executed, 2)
    }
    
    func testUnknownError() throws {
        let future = Future<String> {
            sleep(1)
            throw UnknownError()
        }
        
        future.then { _ in
            XCTFail()
        }
        
        future.catch(CustomError.self) { _ in
            XCTFail()
        }
        
        future.catch { error in
            XCTAssert(error is UnknownError)
        }
        
        sleep(2)
    }
    
    func testUnwrapFutureResult() throws {
        let future = Future<String> {
            throw CustomError()
        }
        
        var completed = false
        
        func check(_ result: FutureResult<String>) {
            XCTAssertThrowsError(try result.assertSuccess())
        }
        
        future.onComplete { result in
            completed = true
            
            check(result)
        }
        
        // To prevent checking before executing the async future
        sleep(1)
        
        XCTAssert(completed)
    }
    
    func testFutureMapping() throws {
        let future = Future { "0" }
        
        let result = future.map { string in
            return Int(string)
        }.map { int in
            return int == 0
        }
        
        XCTAssert(try result.await(for: .seconds(1)))
        XCTAssertEqual(try future.await(for: .seconds(1)), "0")
    }
    
    func testNestedFutureReducing() throws {
        let future = Future { "0" }.replace { string in
            return Future {
                return Int(string)
            }
        }.map { $0 }
        
        XCTAssertEqual(try future.await(for: .seconds(1)), 0)
    }
    
    func testMultipleFutures() throws {
        var done = 0
        
        let future0 = Future { done += 1 }
        let future1 = Future { done += 1 }
        let future2 = Future { done += 1 }
        let future3 = Future { done += 1 }
        
        let futures = [future0, future1, future2, future3]
        
        let superFuture = Future<Void>(futures)

        _ = try superFuture.await()
        XCTAssertEqual(done, 4)
    }
    
    func testManualFuture() throws {
        let future = ManualFuture<String>()
        
        XCTAssertFalse(future.isCompleted)
        
        try future.complete("Hello world")
        
        XCTAssertTrue(future.isCompleted)
        XCTAssertThrowsError(try future.complete(CustomError()))
        XCTAssertThrowsError(try future.complete("Test"))
        
        future.onComplete { result in
            switch result {
            case .expectation(let expectation):
                XCTAssertEqual(expectation, "Hello world")
            default:
                XCTFail()
            }
        }
        
        let future2 = ManualFuture<String>()
        
        try future2.complete(CustomError())
        XCTAssertThrowsError(try future.complete(CustomError()))
        XCTAssertThrowsError(try future.complete("Hello world"))
        
        future2.onComplete { result in
            switch result {
            case .error(let error):
                XCTAssert(error is CustomError)
            default:
                XCTFail()
            }
        }
    }
}

struct UnknownError : Error {}
struct CustomError : Error {}

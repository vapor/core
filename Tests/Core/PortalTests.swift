import XCTest
import libc
@testable import Core

private enum PortalTestError: Error {
    case someError
    case anotherError
}

class PortalTests: XCTestCase {

//    #if os(Linux)
//    /*
//    Temporary until we get libdispatch support on Linux, then remove this section.
//    */
//    static let allTests = [
//        ("testLinux", testLinux)
//    ]
//
//    func testLinux() {
//        print("Not yet available on linux")
//    }
//
//    #else
    static let allTests = [
        ("testPortalResult", testPortalResult),
        ("testPortalFailure", testPortalFailure),
        ("testDuplicateResults", testDuplicateResults),
        ("testDuplicateErrors", testDuplicateErrors)
    ]

    func testPortalResult() throws {
        var array: [Int] = []

        array.append(1)
        let result: Int = try Portal.open { portal in
            array.append(2)
            _ = try background {
                sleep(1)
                array.append(4)
                portal.close(with: 42)
            }
            array.append(3)
        }
        array.append(5)

        XCTAssert(array == [1,2,3,4,5])
        XCTAssert(result == 42)
    }

    func testPortalFailure() {
        var array: [Int] = []

        do {
            array.append(1)
            let _ = try Portal<Int>.open { portal in
                array.append(2)
                _ = try background {
                    sleep(1)
                    array.append(4)
                    portal.close(with: PortalTestError.someError)
                }
                array.append(3)
            }
            XCTFail("Portal should throw")
        } catch PortalTestError.someError {
            // success
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }

        XCTAssert(array == [1,2,3,4])
    }

    func testPortalNotCalled() {
        do {
            let _ = try Portal<Int>.open { portal in
                portal.destroy()
            }
            XCTFail("Should not have passed")
        } catch PortalError.portalNotClosed {
            // pass
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func testPortalTimedOut() {
        do {
            let _ = try Portal<Int>.open(timeout: 0) { portal in
                //
            }
            XCTFail("Should not have passed")
        } catch PortalError.timedOut {
            // pass
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func testTimeout() throws {
        let result = try Portal<Int>.timeout(0) {
            return 1
        }

        XCTAssertEqual(result, 1)
    }

    func testDuplicateResults() throws {
        let response = try Portal<Int>.open { portal in
            portal.close(with: 10)
            // subsequent resolutions should be ignored
            portal.close(with: 400)
        }

        XCTAssert(response == 10)
    }

    func testDuplicateErrors() {
        do {
            let _ = try Portal<Int>.open { portal in
                portal.close(with: PortalTestError.someError)
                // subsequent rejections should be ignored
                portal.close(with: PortalTestError.anotherError)
            }
            XCTFail("Test should not pass")
        } catch PortalTestError.someError {
            // success
        } catch {
            XCTFail("Unexpected error thrown")
        }
    }
}

#if os(Linux)

import XCTest
@testable import DebuggingTests

XCTMain([
    testCase(FooErrorTests.allTests),
    testCase(GeneralTests.allTests),
    testCase(TraceableTests.allTests),
])

#endif
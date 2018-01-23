#if os(Linux)

import XCTest
@testable import DebuggingTests
@testable import FilesTests

XCTMain([
    testCase(FooErrorTests.allTests),
    testCase(GeneralTests.allTests),
    testCase(TraceableTests.allTests),
    testCase(FilesTests.allTests),
])

#endif

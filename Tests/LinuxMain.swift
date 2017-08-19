#if os(Linux)

import XCTest
@testable import CoreTests

XCTMain([
    testCase(FutureTests.allTests),
    testCase(StreamTests.allTests),
])

#endif
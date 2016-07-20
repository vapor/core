#if os(Linux)

import XCTest
@testable import CoreTestSuite

XCTMain([
    testCase(PromiseTests.allTests),
    testCase(UtilityTests.allTests),
    testCase(PercentEncodingTests.allTests),
    testCase(UnsignedIntegerChunkingTests.allTests),
])

#endif

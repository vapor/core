#if os(Linux)

import XCTest
@testable import CoreTests

XCTMain([
    testCase(ArrayTests.allTests),
    testCase(BlackBoxTests.allTests),
    testCase(CacheTests.allTests),
    testCase(JSONTests.allTests),
    testCase(PercentEncodingTests.allTests),
    testCase(PortalTests.allTests),
    testCase(ResultTests.allTests),
    testCase(RFC1123Tests.allTests),
    testCase(SemaphoreTests.allTests),
    testCase(StaticDataBufferTests.allTests),
    testCase(StringTests.allTests),
    testCase(UnsignedIntegerChunkingTests.allTests),
    testCase(URLCodableTests.allTests),
    testCase(UtilityTests.allTests),
    testCase(PolymorphicTests.allTests),
])

#endif

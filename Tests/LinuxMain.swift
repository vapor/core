#if os(Linux)

import XCTest
@testable import CoreTests

XCTMain([
    testCase(StrandTests.allTests),
    testCase(SemaphoreTests.allTests),
    testCase(TimespecTests.allTests),
    testCase(ArrayTests.allTests),
    testCase(BytesTests.allTests),
    testCase(ExtractableTests.allTests),
    testCase(PercentEncodingTests.allTests),
    testCase(PortalTests.allTests),
    testCase(ResultTests.allTests),
    testCase(StaticDataBufferTests.allTests),
    testCase(UnsignedIntegerChunkingTests.allTests),
    testCase(StringTests.allTests),
    testCase(UnsignedIntegerTests.allTests),
    testCase(UtilityTests.allTests),
])

#endif

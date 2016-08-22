#if os(Linux)

import XCTest
@testable import CoreTests

XCTMain([
    testCase(ArrayTests.allTests),
    testCase(BoolTests.allTests),
    testCase(BytesTests.allTests),
    testCase(ExtractableTests.allTests),
    testCase(FileProtocolTests.allTests),
    testCase(PercentEncodingTests.allTests),
    testCase(PortalTests.allTests),
    testCase(ResultTests.allTests),
    testCase(RFC1123Tests.allTests),
    testCase(SemaphoreTests.allTests),
    testCase(StaticDataBufferTests.allTests),
    testCase(StrandTests.allTests),
    testCase(StringTests.allTests),
    testCase(TimespecTests.allTests),
    testCase(UnsignedIntegerChunkingTests.allTests),
    testCase(UnsignedIntegerTests.allTests),
    testCase(UtilityTests.allTests),
])

#endif

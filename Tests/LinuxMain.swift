#if os(Linux)

import XCTest
@testable import CoreTestSuite

XCTMain([
    testCase(ArrayTests.allTests),
    testCase(BoolTests.allTests),
    testCase(BytesTests.allTests),
    testCase(ExtractableTests.allTests),
    testCase(PercentEncodingTests.allTests),
    testCase(PromiseTests.allTests),
    testCase(ResultTests.allTests),
    testCase(StaticDataBufferTests.allTests),
    testCase(UnsignedIntegerChunkingTests.allTests),
    testCase(StringTests.allTests),
    testCase(UnsignedIntegerTests.allTests),
    testCase(UtilityTests.allTests),
])

#endif

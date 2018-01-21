#if os(Linux)

import XCTest
@testable import DebuggingTests
@testable import CodableKitTests

XCTMain([
    testCase(FooErrorTests.allTests),
    testCase(GeneralTests.allTests),
    testCase(TraceableTests.allTests),
    
    testCase(KeyStringDecoderTests.allTests),
])

#endif

#if os(Linux)

@testable import BitsTests
@testable import CodableKitTests
@testable import CoreTests
@testable import DebuggingTests
import XCTest

XCTMain([
	/// Bits
	testCase(Base64Tests.allTests),
	testCase(ByteBufferPeekTests.allTests),
	testCase(ByteBufferRequireTests.allTests),

    /// Codable
    testCase(KeyStringDecoderTests.allTests),

    /// Core
    testCase(CoreTests.allTests),

    /// Debugging
    testCase(FooErrorTests.allTests),
    testCase(GeneralTests.allTests),
    testCase(TraceableTests.allTests),
])

#endif
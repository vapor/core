#if os(Linux)

@testable import BitsTests
@testable import CoreTests
@testable import DebuggingTests
import XCTest

XCTMain([
	/// Bits
	testCase(ByteBufferPeekTests.allTests),
	testCase(ByteBufferRequireTests.allTests),

    /// Core
    testCase(CoreTests.allTests),
    testCase(ReflectableTests.allTests),

    /// Debugging
    testCase(FooErrorTests.allTests),
    testCase(GeneralTests.allTests),
    testCase(TraceableTests.allTests),
])

#endif
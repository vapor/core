import NIO
import XCTest
@testable import Bits

final class ByteBufferTestRequireTests: XCTestCase {
    private let allocator = ByteBufferAllocator()
    private var buf: ByteBuffer! = nil

    func testRequireFixedWidthInteger() {
        buf = allocator.buffer(capacity: 32)
        let first: Int = 1
        let second: Int = 3
        buf.write(integer: first)
        buf.write(integer: second)
        try XCTAssertEqual(buf.requireReadInteger(), first)
        try XCTAssertEqual(buf.requireReadInteger(), second)

        do {
            let _: Int = try buf.requireReadInteger()
            XCTFail()
        } catch _ as ByteBufferReadError {
            XCTAssert(true)
        } catch {
            XCTFail()
        }
    }

    func testRequireString() {
        buf = allocator.buffer(capacity: 32)
        let first = "This String"
        let second = "Is Not That String"
        buf.write(string: first)
        buf.write(string: second)
        try XCTAssertEqual(buf.requireReadString(length: first.count), first)
        try XCTAssertEqual(buf.requireReadString(length: second.count), second)

        do {
            _ = try buf.requireReadString(length: 1)
            XCTFail()
        } catch _ as ByteBufferReadError {
            XCTAssert(true)
        } catch {
            XCTFail()
        }
    }

    func testRequireData() {
        buf = allocator.buffer(capacity: 256)
        let first = Array("My String".utf8)
        let second = Array("My other string".utf8)

        buf.write(bytes: first)
        buf.write(bytes: second)

        try XCTAssertEqual(buf.requireReadData(length: first.count), Data(bytes: first))
        try XCTAssertEqual(buf.requireReadData(length: second.count), Data(bytes: second))

        do {
            _ = try buf.requireReadData(length: 1)
            XCTFail()
        } catch _ as ByteBufferReadError {
            XCTAssert(true)
        } catch {
            XCTFail()
        }
    }

    func testRequireBinaryFloatingPoint() {
        buf = allocator.buffer(capacity: 256)
        let first: Float = 91.235
        let second: Double = 32.476

        buf.write(floatingPoint: first)
        buf.write(floatingPoint: second)

        try XCTAssertEqual(buf.requireBinaryFloatingPoint(), first)
        try XCTAssertEqual(buf.requireBinaryFloatingPoint(), second)

        do {
            let _: Double = try buf.requireBinaryFloatingPoint()
            XCTFail()
        } catch _ as ByteBufferReadError {
            XCTAssert(true)
        } catch {
            XCTFail()
        }
    }

}


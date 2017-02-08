import XCTest
import Core

class BlackBoxTests: XCTestCase {
    static var allTests = [
        ("testStaticDataBufferSubclassing", testStaticDataBufferSubclassing)
    ]

    func testStaticDataBufferSubclassing() throws {
        class MyStaticDataBuffer: StaticDataBuffer {
            init(bytes: Bytes) {
                super.init(bytes: bytes)
            }

            override func next() throws -> Byte? {
                return nil
            }
        }

        let buffer = MyStaticDataBuffer(bytes: "hello".makeBytes())
        XCTAssertEqual(try buffer.next(), nil)
    }
}

import XCTest
import Core
import Bits

class BlackBoxTests: XCTestCase {
    static var allTests = [
        ("testStaticDataBufferSubclassing", testStaticDataBufferSubclassing)
    ]

    func testStaticDataBufferSubclassing() throws {
        class MyStaticDataBuffer: StaticDataBuffer {
            override init<S: Sequence>(bytes: S) where S.Iterator.Element == Byte {
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

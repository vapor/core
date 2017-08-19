import XCTest
@testable import Core

final class StreamTests : XCTestCase {
    func testBasicStream() throws {
        let stream = BasicStream<String>()
        
        var messages = [
            "test",
            "vapor",
            "streams",
            "of",
            "strings"
        ]
        
        var readIndex = 0
        
        stream.stream { message in
            defer { readIndex += 1 }
            XCTAssertEqual(message, messages[readIndex])
        }
        
        for message in messages {
            try stream.write(message).await()
        }
        
        XCTAssertEqual(readIndex, 5)
    }
    
    func testStreamMapping() throws {
        let stream = BasicStream<Int>()
        
        var number = 0
        
        stream.stream { String($0) }.process {
            defer { number += 1 }
            
            XCTAssertEqual(String(number), $0)
        }
        
        for i in 0..<10 {
            try stream.write(i).await()
        }
    }
    
    func testFutureStream() throws {
        let stream = BasicStream<String>()
        
        var executed = false
        
        stream.stream { string in
            return Future {
                string
            }
        }.stream { string in
            return String(string.reversed())
        }.process { string in
            XCTAssertEqual(string, "Hello")
            executed = true
        }
        
        try stream.write("olleH")
        
        sleep(1)
        XCTAssert(executed)
    }

    static let allTests = [
        ("testBasicStream", testBasicStream),
        ("testStreamMapping", testStreamMapping),
        ("testFutureStream", testFutureStream)
    ]
}

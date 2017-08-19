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
        
        stream.process { message in
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
        
        stream.map { String($0) }.process {
            defer { number += 1 }
            
            XCTAssertEqual(String(number), $0)
        }
        
        for i in 0..<10 {
            try stream.write(i).await()
        }
    }
}

import Async
import XCTest
@testable import Files

class FilesTests: XCTestCase {
    func testExample() throws {
        let loop = try DefaultEventLoop(label: "test")
        let file1 = try File(atPath: "/Users/joannisorlandos/Documents/Vapor/vapor/Sources/Development/main.swift")
        let file2 = try File(atPath: "/Users/joannisorlandos/Desktop/kaas.swift")
        let promise = Promise<Void>()
        
//        file.source(on: loop).map(to: String.self) { buffer in
//            return String(bytes: buffer, encoding: .utf8) ?? ""
//        }.drain { string in
//            print(string)
//        }.finally {
//            promise.complete()
//        }
        
        file1.source(on: loop).output(to: file2.sink(on: loop))
        
        try promise.future.await(on: loop)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

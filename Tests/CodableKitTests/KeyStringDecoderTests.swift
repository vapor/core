import CodableKit
import XCTest

class KeyStringDecoderTests: XCTestCase {
    func testSimpleStruct() {
        struct Foo: Decodable {
            var name: String
            var age: Double
            var luckyNumber: Int
            var maybe: UInt32?
        }

        XCTAssertEqual(Foo.codingPath(forKey: \.name).map { $0.stringValue }, ["name"])
        XCTAssertEqual(Foo.codingPath(forKey: \.age).map { $0.stringValue }, ["age"])
        XCTAssertEqual(Foo.codingPath(forKey: \.luckyNumber).map { $0.stringValue }, ["luckyNumber"])
        XCTAssertEqual(Foo.codingPath(forKey: \.maybe).map { $0.stringValue }, ["maybe"])
    }

    func testNestedStruct() {
        struct Foo: Decodable {
            var name: String
            var age: Double
            var luckyNumber: Int
            var bar: Bar
        }

        struct Bar: Decodable {
            var name: String
            var age: Double
            var luckyNumbers: [Int]
            var dict: [String: String]
        }

        XCTAssertEqual(Foo.codingPath(forKey: \.name).map { $0.stringValue }, ["name"])
        XCTAssertEqual(Foo.codingPath(forKey: \.age).map { $0.stringValue }, ["age"])
        XCTAssertEqual(Foo.codingPath(forKey: \.luckyNumber).map { $0.stringValue }, ["luckyNumber"])
        // XCTAssertEqual(Foo.codingPath(forKey: \.bar).map { $0.stringValue }, ["bar"])
        XCTAssertEqual(Foo.codingPath(forKey: \.bar.name).map { $0.stringValue }, ["bar", "name"])
        XCTAssertEqual(Foo.codingPath(forKey: \.bar.age).map { $0.stringValue }, ["bar", "age"])
        // XCTAssertEqual(Foo.codingPath(forKey: \.bar.luckyNumbers).map { $0.stringValue }, ["bar", "luckyNumbers"])
        // XCTAssertEqual(Foo.codingPath(forKey: \.bar.dict).map { $0.stringValue }, ["bar", "dict"])
    }

    static let allTests = [
        ("testSimpleStruct", testSimpleStruct),
        ("testNestedStruct", testNestedStruct),
    ]
}

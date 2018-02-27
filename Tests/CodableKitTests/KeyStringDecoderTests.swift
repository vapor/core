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

    func testProperties() {
        struct User: Decodable {
            var int: Int
            var oint: Int?
            var int8: Int8
            var oint8: Int8?
            var int16: Int16
            var oint16: Int16?
            var int32: Int32
            var oint32: Int32?
            var int64: Int64
            var oint64: Int64?
            var uint: UInt
            var uoint: UInt?
            var uint8: UInt8
            var uoint8: UInt8?
            var uint16: UInt16
            var uoint16: UInt16?
            var uint32: UInt32
            var uoint32: UInt32?
            var uint64: UInt64
            var uoint64: UInt64?

            var uuid: UUID
            var ouuid: UUID?

            var date: Date
            var odate: Date?

            var float: Float
            var ofloat: Float?
            var double: Double
            var odouble: Double?

            var string: String
            var ostring: String?

            var bool: Bool
            var obool: Bool?

            var array: [String]
            var oarray: [String]?

            var dict: [String: String]
            var odict: [String: String]?
        }

        let properties = User.properties()
        XCTAssertEqual(properties.description, "[int: Int, oint: Int?, int8: Int8, oint8: Int8?, int16: Int16, oint16: Int16?, int32: Int32, oint32: Int32?, int64: Int64, oint64: Int64?, uint: UInt, uoint: UInt?, uint8: UInt8, uoint8: UInt8?, uint16: UInt16, uoint16: UInt16?, uint32: UInt32, uoint32: UInt32?, uint64: UInt64, uoint64: UInt64?, uuid: UUID, ouuid: UUID?, date: Date, odate: Date?, float: Float, ofloat: Float?, double: Double, odouble: Double?, string: String, ostring: String?, bool: Bool, obool: Bool?, array: Array<String>, oarray: Array<String>?, dict: Dictionary<String, String>, odict: Dictionary<String, String>?]")
    }

    func testPropertyDepth() {
        struct Pet: Decodable {
            var nickname: String
            var favoriteTreat: String
        }
        struct User: Decodable {
            var pet: Pet
            var name: String
            var age: Int
        }

        XCTAssertEqual(User.properties(depth: 1).description, "[pet: Pet #1, name: String, age: Int]")
        XCTAssertEqual(User.properties(depth: 2).description, "[pet.nickname: String, pet.favoriteTreat: String, name: String, age: Int]")
    }

    static let allTests = [
        ("testSimpleStruct", testSimpleStruct),
        ("testNestedStruct", testNestedStruct),
        ("testProperties", testProperties),
        ("testPropertyDepth", testPropertyDepth),
    ]
}

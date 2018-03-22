import CodableKit
import XCTest

class KeyStringDecoderTests: XCTestCase {
    func testStruct() throws {
        struct Foo: CodableProperties, Decodable {
            var bool: Bool
            var obool: Bool?
            var int: Int
            var oint: Int?
            var sarr: [String]
            var osarr: [String]?
        }

        let properties = try Foo.properties()
        XCTAssertEqual(properties.description, "[bool: Bool, obool: Optional<Bool>, int: Int, oint: Optional<Int>, sarr: Array<String>, osarr: Optional<Array<String>>]")

        try XCTAssertEqual(Foo.property(forKey: \.bool).path, ["bool"])
        try XCTAssert(Foo.property(forKey: \.bool).type is Bool.Type)

        try XCTAssertEqual(Foo.property(forKey: \.obool).path, ["obool"])
        try XCTAssert(Foo.property(forKey: \.obool).type is Bool?.Type)

        try XCTAssertEqual(Foo.property(forKey: \.int).path, ["int"])
        try XCTAssert(Foo.property(forKey: \.int).type is Int.Type)

        try XCTAssertEqual(Foo.property(forKey: \.oint).path, ["oint"])
        try XCTAssert(Foo.property(forKey: \.oint).type is Int?.Type)

        try XCTAssertEqual(Foo.property(forKey: \.sarr).path, ["sarr"])
        try XCTAssert(Foo.property(forKey: \.sarr).type is [String].Type)

        try XCTAssertEqual(Foo.property(forKey: \.osarr).path, ["osarr"])
        try XCTAssert(Foo.property(forKey: \.osarr).type is [String]?.Type)
    }

    func testStructCustomProperties() throws {
        struct CustomStruct: CodableProperties {
            var hi: Bool

            static func properties(depth: Int) throws -> [CodableProperty] {
                return [CodableProperty(Bool.self, at: ["hi"])]
            }

            static func property<T>(forKey keyPath: KeyPath<CustomStruct, T>) throws -> CodableProperty {
                return CodableProperty(Bool.self, at: ["hi"])
            }
        }

        let properties = try CustomStruct.properties()
        XCTAssertEqual(properties.description, "[hi: Bool]")

        try XCTAssertEqual(CustomStruct.property(forKey: \.hi).path, ["hi"])
        try XCTAssert(CustomStruct.property(forKey: \.hi).type is Bool.Type)
    }

    func testNestedStruct() throws {
        struct Foo: CodableProperties, Decodable {
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

        try XCTAssertEqual(Foo.property(forKey: \.name).path, ["name"])
        try XCTAssertEqual(Foo.property(forKey: \.age).path, ["age"])
        try XCTAssertEqual(Foo.property(forKey: \.luckyNumber).path, ["luckyNumber"])
        XCTAssertThrowsError(try Foo.property(forKey: \.bar))
        try XCTAssertEqual(Foo.property(forKey: \.bar.name).path, ["bar", "name"])
        try XCTAssertEqual(Foo.property(forKey: \.bar.age).path, ["bar", "age"])
        try XCTAssertEqual(Foo.property(forKey: \.bar.luckyNumbers).path, ["bar", "luckyNumbers"])
        try XCTAssertEqual(Foo.property(forKey: \.bar.dict).path, ["bar", "dict"])
    }

    func testProperties() throws {
        struct User: CodableProperties, Decodable {
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

        let properties = try User.properties()
        XCTAssertEqual(properties.description, "[int: Int, oint: Optional<Int>, int8: Int8, oint8: Optional<Int8>, int16: Int16, oint16: Optional<Int16>, int32: Int32, oint32: Optional<Int32>, int64: Int64, oint64: Optional<Int64>, uint: UInt, uoint: Optional<UInt>, uint8: UInt8, uoint8: Optional<UInt8>, uint16: UInt16, uoint16: Optional<UInt16>, uint32: UInt32, uoint32: Optional<UInt32>, uint64: UInt64, uoint64: Optional<UInt64>, uuid: UUID, ouuid: Optional<UUID>, date: Date, odate: Optional<Date>, float: Float, ofloat: Optional<Float>, double: Double, odouble: Optional<Double>, string: String, ostring: Optional<String>, bool: Bool, obool: Optional<Bool>, array: Array<String>, oarray: Optional<Array<String>>, dict: Dictionary<String, String>, odict: Optional<Dictionary<String, String>>]")
    }

    func testPropertyDepth() throws {
        struct Pet: Decodable {
            var nickname: String
            var favoriteTreat: String
        }
        struct User: CodableProperties, Decodable {
            var pet: Pet
            var name: String
            var age: Int
        }

        try XCTAssertEqual(User.properties(depth: 1).description, "[pet: Pet #1, name: String, age: Int]")
        try XCTAssertEqual(User.properties(depth: 2).description, "[pet.nickname: String, pet.favoriteTreat: String, name: String, age: Int]")
    }

    func testPropertyA() throws {
        final class A: CodableProperties, Decodable {
            public var id: UUID?
            public var date: Date
            public var length: Double
            public var isOpen: Bool
        }
        try XCTAssertEqual(A.properties().description, "[id: Optional<UUID>, date: Date, length: Double, isOpen: Bool]")
    }

    func testThrows() throws {
        struct FooDesc: CodableProperties, Decodable {
            var name: String
            var description: String {
                return "foo"
            }
        }

        XCTAssertThrowsError(try FooDesc.property(forKey: \.description).description)
    }

    static let allTests = [
        ("testStruct", testStruct),
        ("testStructCustomProperties", testStructCustomProperties),
        ("testNestedStruct", testNestedStruct),
        ("testProperties", testProperties),
        ("testPropertyDepth", testPropertyDepth),
        ("testPropertyA", testPropertyA),
        ("testThrows", testThrows),
    ]
}

@testable import Core
import XCTest

class ReflectableTests: XCTestCase {
    func testStruct() throws {
        enum Pet: String, ReflectionDecodable, Decodable {
            static func reflectDecoded() -> (Pet, Pet) { return (.cat, .dog) }
            case cat, dog
        }

        enum Direction: UInt8, ReflectionDecodable, Decodable, CaseIterable {
            static let allCases: [Direction] = [.left, .right]
            case left, right
        }

        struct Foo: Reflectable, Decodable {
            var bool: Bool
            var obool: Bool?
            var int: Int
            var oint: Int?
            var sarr: [String]
            var osarr: [String]?
            var pet: Pet
            var opet: Pet?
            var dir: Direction
            var odir: Direction?
        }

        let properties = try Foo.reflectProperties()
        XCTAssertEqual(properties.description, """
        [bool: Bool, obool: Optional<Bool>, int: Int, oint: Optional<Int>, sarr: Array<String>, osarr: Optional<Array<String>>, pet: Pet #1, opet: Optional<Pet #1>, dir: Direction #1, odir: Optional<Direction #1>]
        """)

        try XCTAssertEqual(Foo.reflectProperty(forKey: \.bool)?.path, ["bool"])
        try XCTAssert(Foo.reflectProperty(forKey: \.bool)?.type is Bool.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.obool)?.path, ["obool"])
        try XCTAssert(Foo.reflectProperty(forKey: \.obool)?.type is Bool?.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.int)?.path, ["int"])
        try XCTAssert(Foo.reflectProperty(forKey: \.int)?.type is Int.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.oint)?.path, ["oint"])
        try XCTAssert(Foo.reflectProperty(forKey: \.oint)?.type is Int?.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.sarr)?.path, ["sarr"])
        try XCTAssert(Foo.reflectProperty(forKey: \.sarr)?.type is [String].Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.osarr)?.path, ["osarr"])
        try XCTAssert(Foo.reflectProperty(forKey: \.osarr)?.type is [String]?.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.pet)?.path, ["pet"])
        try XCTAssert(Foo.reflectProperty(forKey: \.pet)?.type is Pet.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.opet)?.path, ["opet"])
        try XCTAssert(Foo.reflectProperty(forKey: \.opet)?.type is Pet?.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.dir)?.path, ["dir"])
        try XCTAssert(Foo.reflectProperty(forKey: \.dir)?.type is Direction.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.odir)?.path, ["odir"])
        try XCTAssert(Foo.reflectProperty(forKey: \.odir)?.type is Direction?.Type)
    }

    func testCaseIterableExtension() throws {
        #if swift(>=4.2)
        // Should throw since there's only 1 case
        enum FakePet: String, CaseIterable, ReflectionDecodable, Decodable {
            case dragon
        }

        enum Pet: String, CaseIterable, ReflectionDecodable, Decodable {
            case cat, dog
        }

        struct Foo: Reflectable, Decodable {
            var bool: Bool
            var pet: Pet
        }

        let properties = try Foo.reflectProperties()
        XCTAssertEqual(properties.description, """
        [bool: Bool, pet: Pet]
        """)

        try XCTAssertEqual(Foo.reflectProperty(forKey: \.bool)?.path, ["bool"])
        try XCTAssert(Foo.reflectProperty(forKey: \.bool)?.type is Bool.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.pet)?.path, ["pet"])
        try XCTAssert(Foo.reflectProperty(forKey: \.pet)?.type is Pet.Type)
        try XCTAssertThrowsError(FakePet.reflectDecoded(), "FakePet should throw")
        #else
        XCTAssertTrue(true)
        #endif
    }

    func testNonOptionalsOnly() throws {
        struct Foo: Reflectable, Decodable {
            var bool: Bool
            var obool: Bool?
            var int: Int
            var oint: Int?
            var sarr: [String]
            var osarr: [String]?
        }

        let properties = try Foo.reflectProperties().optionalsRemoved()
        XCTAssertEqual(properties.description, "[bool: Bool, int: Int, sarr: Array<String>]")

        try XCTAssertEqual(Foo.reflectProperty(forKey: \.bool)?.path, ["bool"])
        try XCTAssert(Foo.reflectProperty(forKey: \.bool)?.type is Bool.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.int)?.path, ["int"])
        try XCTAssert(Foo.reflectProperty(forKey: \.int)?.type is Int.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.sarr)?.path, ["sarr"])
        try XCTAssert(Foo.reflectProperty(forKey: \.sarr)?.type is [String].Type)
    }

    func testStructCustomProperties() throws {
        struct User: Reflectable {
            var firstName: String
            var lastName: String

            static func reflectProperties(depth: Int) throws -> [ReflectedProperty] {
                switch depth {
                case 0: return [.init(String.self, at: ["first_name"]), .init(String.self, at: ["last_name"])]
                default: return []
                }
            }

            static func anyReflectProperty(valueType: Any.Type, keyPath: AnyKeyPath) throws -> ReflectedProperty? {
                let key: String
                switch keyPath {
                case \User.firstName: key = "first_name"
                case \User.lastName: key = "last_name"
                default: return nil
                }
                return .init(any: valueType, at: [key])
            }
        }

        let properties = try User.reflectProperties(depth: 0)
        XCTAssertEqual(properties.description, "[first_name: String, last_name: String]")
        try XCTAssertEqual(User.reflectProperty(forKey: \.firstName)?.path, ["first_name"])
        try XCTAssert(User.reflectProperty(forKey: \.firstName)?.type is String.Type)
        try XCTAssertEqual(User.reflectProperty(forKey: \.lastName)?.path, ["last_name"])
        try XCTAssert(User.reflectProperty(forKey: \.lastName)?.type is String.Type)
    }

    func testNestedStruct() throws {
        struct Foo: Reflectable, Decodable {
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

        try XCTAssertEqual(Foo.reflectProperty(forKey: \.name)?.path, ["name"])
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.age)?.path, ["age"])
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.luckyNumber)?.path, ["luckyNumber"])
        XCTAssertThrowsError(try Foo.reflectProperty(forKey: \.bar))
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.bar.name)?.path, ["bar", "name"])
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.bar.age)?.path, ["bar", "age"])
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.bar.luckyNumbers)?.path, ["bar", "luckyNumbers"])
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.bar.dict)?.path, ["bar", "dict"])
    }

    func testProperties() throws {
        struct User: Reflectable, Decodable {
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

        let properties = try User.reflectProperties()
        XCTAssertEqual(properties.description, "[int: Int, oint: Optional<Int>, int8: Int8, oint8: Optional<Int8>, int16: Int16, oint16: Optional<Int16>, int32: Int32, oint32: Optional<Int32>, int64: Int64, oint64: Optional<Int64>, uint: UInt, uoint: Optional<UInt>, uint8: UInt8, uoint8: Optional<UInt8>, uint16: UInt16, uoint16: Optional<UInt16>, uint32: UInt32, uoint32: Optional<UInt32>, uint64: UInt64, uoint64: Optional<UInt64>, uuid: UUID, ouuid: Optional<UUID>, date: Date, odate: Optional<Date>, float: Float, ofloat: Optional<Float>, double: Double, odouble: Optional<Double>, string: String, ostring: Optional<String>, bool: Bool, obool: Optional<Bool>, array: Array<String>, oarray: Optional<Array<String>>, dict: Dictionary<String, String>, odict: Optional<Dictionary<String, String>>]")
    }

    func testPropertyDepth() throws {
        struct Pet: Decodable {
            var name: String
            var age: Int
        }
        
        struct User: Reflectable, Decodable {
            var id: UUID?
            var pet: Pet
            var name: String
            var age: Int
        }

        try XCTAssertEqual(User.reflectProperties(depth: 0).description, "[id: Optional<UUID>, pet: Pet #1, name: String, age: Int]")
        try XCTAssertEqual(User.reflectProperties(depth: 1).description, "[pet.name: String, pet.age: Int]")
        try XCTAssertEqual(User.reflectProperties(depth: 2).description, "[]")
    }

    func testPropertyA() throws {
        final class A: Reflectable, Decodable {
            public var id: UUID?
            public var date: Date
            public var length: Double
            public var isOpen: Bool
        }
        try XCTAssertEqual(A.reflectProperties().description, "[id: Optional<UUID>, date: Date, length: Double, isOpen: Bool]")
    }

    func testGH112() throws {
        /// A single entry of a Todo list.
        final class Todo: FooModel, Decodable {
            /// The unique identifier for this `Todo`.
            var id: Int?

            /// A title describing what this `Todo` entails.
            var title: String

            /// Creates a new `Todo`.
            init(id: Int? = nil, title: String) {
                self.id = id
                self.title = title
            }
        }

        try XCTAssertEqual(Todo.reflectProperties().description, "[id: Optional<Int>, title: String]")
        try XCTAssertEqual(Todo.reflectProperty(forKey: \.id)?.path, ["id"])
        try XCTAssertEqual(Todo.reflectProperty(forKey: \.title)?.path, ["title"])
        try XCTAssertEqual(Todo.reflectProperty(forKey: Todo.idKey)?.path, ["id"])

    }

    func testCustomCodingKeys() throws {
        final class Team: Reflectable, Decodable {
            var id: Int?
            var name: String
            enum CodingKeys: String, CodingKey {
                case id = "id"
                case name = "name_asdf"
            }
            init() { fatalError() }
        }
        try XCTAssertEqual(Team.reflectProperty(forKey: \.id)?.path, ["id"])
        try XCTAssertEqual(Team.reflectProperty(forKey: \.name)?.path, ["name_asdf"])
        try XCTAssertEqual(Team.reflectProperties().description, "[id: Optional<Int>, name_asdf: String]")
    }

    func testCache() throws {
        final class A: Reflectable, Decodable {
            public var b: String
        }

        for _ in 0..<1_000 {
            try XCTAssertEqual(A.reflectProperty(forKey: \.b)?.path, ["b"])
        }
    }

    func testArrayNested() throws {
        struct Pet: Codable {
            var name: String
            var type: String
        }

        struct Person: Reflectable, Codable {
            var id: Int?
            var title: String
            var pets: [Pet]
        }

        try XCTAssertEqual(Person.reflectProperties().description, "[id: Optional<Int>, title: String, pets: Array<Pet #1>]")
        XCTAssertThrowsError(try Person.reflectProperty(forKey: \.pets))
    }

    /// https://github.com/vapor/core/issues/119
    func testGH119() throws {
        enum PetType: Int, Codable {
            case cat, dog
        }
        struct Pet: Reflectable, Codable {
            var name: String
            var type: PetType
        }
        try XCTAssertEqual(Pet.reflectProperties().description, "[name: String, type: Int]")
    }

    static let allTests = [
        ("testStruct", testStruct),
        ("testCaseIterableExtension", testCaseIterableExtension),
        ("testNonOptionalsOnly", testNonOptionalsOnly),
        ("testStructCustomProperties", testStructCustomProperties),
        ("testNestedStruct", testNestedStruct),
        ("testProperties", testProperties),
        ("testPropertyDepth", testPropertyDepth),
        ("testPropertyA", testPropertyA),
        ("testGH112", testGH112),
        ("testCustomCodingKeys", testCustomCodingKeys),
        ("testCache", testCache),
        ("testArrayNested", testArrayNested),
        ("testGH119", testGH119),
    ]
}

protocol Model: Reflectable {
    associatedtype ID
    static var idKey: WritableKeyPath<Self, ID?> { get }
}

protocol FooModel: Model where ID == Int {
    var id: Int? { get set }
}

extension FooModel {
    static var idKey: WritableKeyPath<Self, Int?> {
        return \.id
    }
}

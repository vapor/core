@testable import Core
import XCTest

class ReflectableTests: XCTestCase {
    func testCodableReflection() throws {
        struct Foo: Reflectable, Codable {
            enum Direction: UInt8, ReflectionDecodable, Codable, CaseIterable {
                static let allCases: [Direction] = [.left, .right]
                case left, right
            }
            struct Nested: Codable, ReflectionDecodable, Equatable {
                static func reflectDecoded() -> (Foo.Nested, Foo.Nested) {
                    return (Nested(a: "0", b: 0), Nested(a: "1", b: 1))
                }

                static var isBaseType: Bool { return false }
                var a: String
                var b: Int
            }
            var bool: Bool
            var obool: Bool?
            var int: Int
            var oint: Int?
            var sarr: [String]
            var osarr: [String]?
            var sdict: [String: String]
            var odict: [String: String]?
            var dir: Direction
            var odir: Direction?
            var nested: Nested
            var onested: Nested?
        }

        let properties = try Foo.reflectProperties()
        XCTAssertEqual("\(properties)", "[bool: Bool, obool: Optional<Bool>, int: Int, oint: Optional<Int>, sarr: Array<String>, osarr: Optional<Array<String>>, sdict: Dictionary<String, String>, odict: Optional<Dictionary<String, String>>, dir: Direction, odir: Optional<Direction>, nested: Nested, onested: Optional<Nested>]")
        let properties2 = try Foo.reflectProperties(depth: 1)
        XCTAssertEqual("\(properties2)", "[nested.a: String, nested.b: Int, onested.a: String, onested.b: Int]")

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
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.sdict)?.path, ["sdict"])
        try XCTAssert(Foo.reflectProperty(forKey: \.sdict)?.type is [String: String].Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.odict)?.path, ["odict"])
        try XCTAssert(Foo.reflectProperty(forKey: \.odict)?.type is [String: String]?.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.dir)?.path, ["dir"])
        try XCTAssert(Foo.reflectProperty(forKey: \.dir)?.type is Foo.Direction.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.odir)?.path, ["odir"])
        try XCTAssert(Foo.reflectProperty(forKey: \.odir)?.type is Foo.Direction?.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.nested.a)?.path, ["nested", "a"])
        try XCTAssert(Foo.reflectProperty(forKey: \.nested.a)?.type is String.Type)

        try XCTAssertEqual(Foo.reflectProperty(forKey: \.nested)?.path, ["nested"])
        try XCTAssert(Foo.reflectProperty(forKey: \.nested)?.type is Foo.Nested.Type)
        try XCTAssertEqual(Foo.reflectProperty(forKey: \.onested)?.path, ["onested"])
        try XCTAssert(Foo.reflectProperty(forKey: \.onested)?.type is Foo.Nested?.Type)
    }

    static var allTests = [
        ("testCodableReflection", testCodableReflection)
        ]
}

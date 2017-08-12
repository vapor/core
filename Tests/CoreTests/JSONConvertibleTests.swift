import XCTest
import JSON
import Core

class JSONConvertibleTests: XCTestCase {
    func testJSONDecode() throws {
        let data = """
        {
            "name": {
                "first_name": "Gertrude",
                "last": "Computer"
            },
            "age": 109,
            "lucky_numbers": [3.14, 5.0]
        }
        """.data(using: .utf8)!

        let person = try Person(json: data)
        XCTAssertEqual(person.name.full, "Gertrude Computer")
        XCTAssertEqual(person.age, 109)
        XCTAssertEqual(person.luckyNumbers, [3.14, 5.0])
    }

    func testJSONArrayDecode() throws {
        let data = """
        [
            {
                "name": {
                    "first_name": "Gertrude",
                    "last": "Computer"
                },
                "age": 109,
                "lucky_numbers": [3.14, 5.0]
            },
            {
                "name": {
                    "first_name": "Gertrude",
                    "last": "Computer"
                },
                "age": 109,
                "lucky_numbers": [3.14, 5.0]
            }
        ]
        """.data(using: .utf8)!

        let array = try [Person](json: data)
        XCTAssertEqual(array.count, 2)
    }

    static let allTests = [
        ("testJSONDecode", testJSONDecode),
        ("testJSONArrayDecode", testJSONArrayDecode)
    ]
}

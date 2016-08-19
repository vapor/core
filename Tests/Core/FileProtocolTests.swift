import Foundation
import XCTest

@testable import Core

class FileProtocolTests: XCTestCase {
    static let allTests = [
        ("testLoad", testLoad),
        ("testSave", testSave),
    ]

    func testLoad() throws {
        let file = DataFile()
        let bytes = try file.load(path: #file)
        XCTAssert(bytes.string.contains("foobar")) // inception
    }

    func testSave() {
        let file = DataFile()
        do {
            try file.save(bytes: [], to: #file)
            XCTFail("Shouldn't have saved.")
        } catch DataFile.Error.unimplemented {
            //
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
}

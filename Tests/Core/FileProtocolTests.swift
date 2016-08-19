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

    func testLoadFail() throws {
        let path = "!!!ferret!!!"
        do {
            let file = DataFile()
            _ = try file.load(path: path)
            XCTFail("Shouldn't have loaded")
        } catch DataFile.Error.fileLoad(let p) {
            XCTAssertEqual(path, p)
        } catch {
            XCTFail("Wrong error: \(error)")
        }
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

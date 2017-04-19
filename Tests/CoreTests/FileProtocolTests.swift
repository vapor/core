import Foundation
import XCTest

@testable import Core

class FileProtocolTests: XCTestCase {
    static let allTests = [
        ("testLoad", testLoad),
        ("testLoadFail", testLoadFail),
        ("testSave", testSave),
    ]

    func testLoad() throws {
        let file = DataFile()
        let bytes = try file.read(at: #file)
        XCTAssert(bytes.makeString().contains("foobar")) // inception
    }

    func testLoadFail() throws {
        let path = "!!!ferret!!!"

        do {
            _ = try DataFile.read(at: path)
            XCTFail("Shouldn't have loaded")
        } catch DataFileError.load {
            // ok
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testSave() throws {
        let writeableDir = #file.components(separatedBy: "/").dropLast().joined(separator: "/")
        let filePath = writeableDir + "/testfile.text"
        do {
            _ = try DataFile.read(at: filePath)
            var message = "Filepath shouldn't already exist, a previous test likely failed."
            message += "\nDelete the file at `\(filePath)` before continuing ..."
            XCTFail(message)
            return
        } catch DataFileError.load {
            // ok
        } // will throw other errors here

        let create = "TEST FILE --- DELETE IF FOUND"
        try DataFile.write(create.makeBytes(), to: filePath)
        let createRecovered = try DataFile.read(at: filePath)
        XCTAssertEqual(create, createRecovered.makeString())

        let overwrite = "new contents test ... TEST FILE --- DELETE IF FOUND"
        try DataFile.write(overwrite.makeBytes(), to: filePath)
        let overwriteRecovered = try DataFile.read(at: filePath)
        XCTAssertEqual(overwrite, overwriteRecovered.makeString())

        try DataFile.delete(at: filePath)
    }

    func testDataFileDebugging() {
        XCTAssertEqual(DataFileError.readableName, "Data File Error")
        XCTAssertTrue(DataFileError.create(path: "foo").printable.contains("missing write permissions"))
        XCTAssertTrue(DataFileError.load(path: "foo").printable.contains("missing read permissions"))
        let unspecified = DataFileError.unspecified(PortalError.notClosed)
        XCTAssertTrue(unspecified.printable.contains("not originally supported by this version"))
    }
}

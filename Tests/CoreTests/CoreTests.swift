import Core
import XCTest

class CoreTests: XCTestCase {
    func testProcessExecute() throws {
        #if !os(iOS) && !os(tvOS) && !os(watchOS)
        try XCTAssertEqual(Process.execute("/bin/echo", "hi"), "hi")
        #endif
    }
    
    func testProcessExecuteCurl() throws {
        #if !os(iOS) && !os(tvOS) && !os(watchOS)
        let res = try Process.execute("/usr/bin/curl", "--verbose", "https://vapor.codes")
        XCTAssertEqual(res.contains("<title>Vapor"), true)
        #endif
    }

    func testProcessAsyncExecute() throws {
        #if !os(iOS) && !os(tvOS) && !os(watchOS)
        let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        var lastOutput: ProcessOutput?
        let status = try Process.asyncExecute("/bin/echo", "hi", on: eventLoop) { output in
            lastOutput = output
        }.wait()
        XCTAssertEqual(status, 0)
        if let output = lastOutput {
            switch output {
            case .stderr: XCTFail("stderr")
            case .stdout(let data): XCTAssertEqual(String(data: data, encoding: .utf8), "hi\n")
            }
        } else {
            XCTFail("no output")
        }
        #endif
    }

    func testProcessExecuteMissing() throws {
        #if !os(iOS) && !os(tvOS) && !os(watchOS)
        XCTAssertThrowsError(try Process.execute("foo", "hi"), "hi")
        #endif
    }

    func testBase64() {
        let original = Data("The quick brown fox jumps over 13 lazy dogs.".utf8)
        XCTAssertEqual(original.base64EncodedString(), "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIDEzIGxhenkgZG9ncy4=")
        XCTAssertEqual(Data(base64Encoded: original.base64EncodedString()), original)
    }

    func testBase64URL() {
        let original = Data("The quick brown fox jumps over 13 lazy dogs.".utf8)
        XCTAssertEqual(original.base64URLEncodedString(), "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIDEzIGxhenkgZG9ncy4")
        XCTAssertEqual(Data(base64URLEncoded: original.base64URLEncodedString()), original)
    }

    func testBase64URLEscaping() {
        do {
            let data = Data(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x98, 0x99, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9])
            XCTAssertEqual(data.base64EncodedString(), "AAECAwQFBgcICRAREhMUFRYXGBkgISIjJCUmJygpMDEyMzQ1Njc4OUBBQkNERUZHSElQUVJTVFVWV1hZYGFiY2RlZmdoaXBxcnN0dXZ3eHmAgYKDhIWGh4iJkJGSk5SVmJmgoaKjpKWmp6ipsLGys7S1tre4ucDBwsPExcbHyMnQ0dLT1NXW19jZ8PHy8/T19vf4+Q==")
            XCTAssertEqual(data.base64URLEncodedString(), "AAECAwQFBgcICRAREhMUFRYXGBkgISIjJCUmJygpMDEyMzQ1Njc4OUBBQkNERUZHSElQUVJTVFVWV1hZYGFiY2RlZmdoaXBxcnN0dXZ3eHmAgYKDhIWGh4iJkJGSk5SVmJmgoaKjpKWmp6ipsLGys7S1tre4ucDBwsPExcbHyMnQ0dLT1NXW19jZ8PHy8_T19vf4-Q")
            XCTAssertEqual(data.base64EncodedString(), data.base64EncodedString().base64URLEscaped().base64URLUnescaped())
            XCTAssertEqual(Data(data.base64EncodedString().utf8), Data(data.base64EncodedString().utf8).base64URLEscaped().base64URLUnescaped())
        }
        do {
            let data = Data(bytes: [0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x98, 0x99, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9])
            XCTAssertEqual(data.base64EncodedString(), "AgMEBQYHCAkQERITFBUWFxgZICEiIyQlJicoKTAxMjM0NTY3ODlAQUJDREVGR0hJUFFSU1RVVldYWWBhYmNkZWZnaGlwcXJzdHV2d3h5gIGCg4SFhoeIiZCRkpOUlZiZoKGio6SlpqeoqbCxsrO0tba3uLnAwcLDxMXGx8jJ0NHS09TV1tfY2fDx8vP09fb3+Pk=")
            XCTAssertEqual(data.base64URLEncodedString(), "AgMEBQYHCAkQERITFBUWFxgZICEiIyQlJicoKTAxMjM0NTY3ODlAQUJDREVGR0hJUFFSU1RVVldYWWBhYmNkZWZnaGlwcXJzdHV2d3h5gIGCg4SFhoeIiZCRkpOUlZiZoKGio6SlpqeoqbCxsrO0tba3uLnAwcLDxMXGx8jJ0NHS09TV1tfY2fDx8vP09fb3-Pk")
            XCTAssertEqual(data.base64EncodedString(), data.base64EncodedString().base64URLEscaped().base64URLUnescaped())
            XCTAssertEqual(Data(data.base64EncodedString().utf8), Data(data.base64EncodedString().utf8).base64URLEscaped().base64URLUnescaped())
        }
    }

    func testHexEncodedString() throws {
        XCTAssertEqual(Data("hello".utf8).hexEncodedString(), "68656c6c6f")
        XCTAssertEqual(Data("hello".utf8).hexEncodedString(uppercase: true), "68656C6C6F")
    }

    func testHeaderValue() throws {
        func parse(_ string: String) throws -> HeaderValue {
            guard let value = HeaderValue.parse(string) else {
                throw CoreError(identifier: "headerValueParse", reason: "Could not parse: \(string)")
            }
            return value
        }

        // content-disposition
        do {
            let header = try parse("""
            form-data; name="multinamed[]"; filename=""
            """)
            XCTAssertEqual(header.value, "form-data")
            XCTAssertEqual(header.parameters["name"], "multinamed[]")
            XCTAssertEqual(header.parameters["filename"], "")
            XCTAssertEqual(header.parameters.count, 2)
        }

        // content type no charset
        do {
            let header = try parse("""
            application/json
            """)
            XCTAssertEqual(header.value, "application/json")
            XCTAssertEqual(header.parameters.count, 0)
        }

        // content type
        do {
            let header = try parse("""
            application/json; charset=utf8
            """)
            XCTAssertEqual(header.value, "application/json")
            XCTAssertEqual(header.parameters["charset"], "utf8")
            XCTAssertEqual(header.parameters.count, 1)
        }

        // quoted content type
        do {
            let header = try parse("""
            application/json; charset="utf8"
            """)
            XCTAssertEqual(header.value, "application/json")
            XCTAssertEqual(header.parameters["charset"], "utf8")
            XCTAssertEqual(header.parameters.count, 1)
        }

        // random letters
        do {
            let header = try parse("""
            af332r92832llgalksdfjsjf
            """)
            XCTAssertEqual(header.value, "af332r92832llgalksdfjsjf")
            XCTAssertEqual(header.parameters.count, 0)
        }

        // empty value
        do {
            let header = try parse("""
            form-data; name=multinamed[]; filename=
            """)
            XCTAssertEqual(header.value, "form-data")
            XCTAssertEqual(header.parameters["name"], "multinamed[]")
            XCTAssertEqual(header.parameters["filename"], "")
            XCTAssertEqual(header.parameters.count, 2)
        }

        // empty value with trailing
        do {
            let header = try parse("""
            form-data; name=multinamed[]; filename=; foo=bar
            """)
            XCTAssertEqual(header.value, "form-data")
            XCTAssertEqual(header.parameters["name"], "multinamed[]")
            XCTAssertEqual(header.parameters["filename"], "")
            XCTAssertEqual(header.parameters["foo"], "bar")
            XCTAssertEqual(header.parameters.count, 3)
        }

        // escaped quote
        do {
            let header = try parse("""
            application/json; charset="u\\"t\\"f8"
            """)
            XCTAssertEqual(header.value, "application/json")
            XCTAssertEqual(header.parameters["charset"], "u\"t\"f8")
            XCTAssertEqual(header.parameters.count, 1)
        }

        // flag style
        do {
            let header = try parse("""
            id=foo; HttpOnly; Secure; foo=bar; Hello
            """)
            XCTAssertEqual(header.value, "id=foo")
            XCTAssertEqual(header.parameters["HTTPONLY"], "")
            XCTAssertEqual(header.parameters["secure"], "")
            XCTAssertEqual(header.parameters["foo"], "bar")
            XCTAssertEqual(header.parameters["hello"], "")
            XCTAssertEqual(header.parameters.count, 4)
        }
    }

    static let allTests = [
        ("testProcessExecute", testProcessExecute),
        ("testProcessAsyncExecute", testProcessAsyncExecute),
        ("testProcessExecuteMissing", testProcessExecuteMissing),
        ("testBase64", testBase64),
        ("testBase64URL", testBase64URL),
        ("testBase64URLEscaping", testBase64URLEscaping),
        ("testHexEncodedString", testHexEncodedString),
        ("testHeaderValue", testHeaderValue),
    ]
}

import Foundation
import XCTest

@testable import Core

class PercentEncodingTests: XCTestCase {
    static let allTests = [
        ("testEncoding", testEncoding),
        ("testEncodingShould", testEncodingShould),
        ("testEncodingZero", testEncodingZero),
        ("testDecoding", testDecoding),
        ("testDecodingInvalidLength", testDecodingInvalidLength),
        ("testDecodingInvalidCharacters", testDecodingInvalidCharacters),
        ("testDecodingExtra", testDecodingExtra),
        ("testDecodingTransform", testDecodingTransform),
        ("testDecodingArraySlice", testDecodingArraySlice),
        ("testDecodingArraySliceTransform", testDecodingArraySliceTransform),
    ]

    func testEncoding() throws {
        try utf8TestCases.forEach { character, encoding in
            let bytes = character.utf8
            let encoded = try percentEncoded(bytes.array)
            let string = encoded.string.uppercased()
            XCTAssertTrue(string == encoding, "\(character) -- \(string) didn't equal expected encoding \(encoding)")

        }
    }

    func testEncodingShould() throws {
        let bytes: Bytes = [.f, .a, .zero]
        let result = try percentEncoded(bytes) { byte in
            return byte != .a
        }

        XCTAssertEqual(result, "%66a%30".bytes)
    }

    func testEncodingZero() throws {
        let bytes: Bytes = [0]
        let result = try percentEncoded(bytes) { byte in
            return byte != .a
        }

        XCTAssertEqual(result, "%00".bytes)
    }

    func testDecoding() {
        utf8TestCases.forEach { character, encoding in
            let encoded = encoding.utf8.array
            guard let decoded = percentDecoded(encoded) else {
                XCTFail("Unable to percent decode string: \(encoded)")
                return
            }
            let decodedString = decoded.string
            XCTAssert(decodedString == character, "\(character) -- \(decodedString) didn't equal expected decoding: \(character)")
        }
    }

    func testDecodingInvalidLength() {
        let input = "%2D%A".bytes // last character is invalid, only 1 character
        let result = percentDecoded(input)
        XCTAssertNil(result)
    }

    func testDecodingInvalidCharacters() {
        let result = percentDecoded("%--".bytes)
        XCTAssertNil(result)
    }

    func testDecodingExtra() {
        guard let result = percentDecoded("%FF%00A".bytes) else {
            XCTFail("Unable to decode.")
            return
        }

        let expected: Bytes = [0xFF, 0x0, .A]
        XCTAssertEqual(result, expected)
    }

    func testDecodingTransform() {
        let transform: (Byte) -> (Byte) = { byte in
            if byte == .plus {
                return .space
            } else {
                return byte
            }
        }

        guard let result = percentDecoded("%FF+%00".bytes, nonEncodedTransform: transform) else {
            XCTFail("Unable to decode.")
            return
        }

        let expected: Bytes = [0xFF, .space, 0x0]
        XCTAssertEqual(result, expected)
    }

    func testDecodingArraySlice() {
        let slice = "%FF+%00A".bytes[0...6]
        guard let result = percentDecoded(slice) else {
            XCTFail("Unable to decode.")
            return
        }

        let expected: Bytes = [0xFF, .plus, 0x0]
        XCTAssertEqual(result, expected)
    }

    func testDecodingArraySliceTransform() {
        let transform: (Byte) -> (Byte) = { byte in
            if byte == .plus {
                return .space
            } else {
                return byte
            }
        }

        let slice = "%FF+%00A".bytes[0...6]
        guard let result = percentDecoded(slice, nonEncodedTransform: transform) else {
            XCTFail("Unable to decode.")
            return
        }

        let expected: Bytes = [0xFF, .space, 0x0]
        XCTAssertEqual(result, expected)
    }
}


private let utf8TestCases: [String: String] = [
    "#": "%23",
    "$": "%24",
    "%": "%25",
    "&": "%26",
    "'": "%27",
    "(": "%28",
    ")": "%29",
    "*": "%2A",
    "+": "%2B",
    ",": "%2C",
    "-": "%2D",
    ".": "%2E",
    "/": "%2F",
    "0": "%30",
    "1": "%31",
    "2": "%32",
    "3": "%33",
    "4": "%34",
    "5": "%35",
    "6": "%36",
    "7": "%37",
    "8": "%38",
    "9": "%39",
    ":": "%3A",
    ";": "%3B",
    "<": "%3C",
    "=": "%3D",
    ">": "%3E",
    "?": "%3F",
    "@": "%40",
    "A": "%41",
    "B": "%42",
    "C": "%43",
    "D": "%44",
    "E": "%45",
    "F": "%46",
    "G": "%47",
    "H": "%48",
    "I": "%49",
    "J": "%4A",
    "K": "%4B",
    "L": "%4C",
    "M": "%4D",
    "N": "%4E",
    "O": "%4F",
    "P": "%50",
    "Q": "%51",
    "R": "%52",
    "S": "%53",
    "T": "%54",
    "U": "%55",
    "V": "%56",
    "W": "%57",
    "X": "%58",
    "Y": "%59",
    "Z": "%5A",
    "[": "%5B",
    "\\": "%5C",
    "]": "%5D",
    "^": "%5E",
    "_": "%5F",
    "`": "%60",
    "a": "%61",
    "b": "%62",
    "c": "%63",
    "d": "%64",
    "e": "%65",
    "f": "%66",
    "g": "%67",
    "h": "%68",
    "i": "%69",
    "j": "%6A",
    "k": "%6B",
    "l": "%6C",
    "m": "%6D",
    "n": "%6E",
    "o": "%6F",
    "p": "%70",
    "q": "%71",
    "r": "%72",
    "s": "%73",
    "t": "%74",
    "u": "%75",
    "v": "%76",
    "w": "%77",
    "x": "%78",
    "y": "%79",
    "z": "%7A",
    "{": "%7B",
    "|": "%7C",
    "}": "%7D",
    "~": "%7E",
    "¡": "%C2%A1",
    "¢": "%C2%A2",
    "£": "%C2%A3",
    "¤": "%C2%A4",
    "¥": "%C2%A5",
    "¦": "%C2%A6",
    "§": "%C2%A7",
    "¨": "%C2%A8",
    "©": "%C2%A9",
    "ª": "%C2%AA",
    "«": "%C2%AB",
    "¬": "%C2%AC",
    "­": "%C2%AD",
    "®": "%C2%AE",
    "¯": "%C2%AF",
    "°": "%C2%B0",
    "±": "%C2%B1",
    "²": "%C2%B2",
    "³": "%C2%B3",
    "´": "%C2%B4",
    "µ": "%C2%B5",
    "¶": "%C2%B6",
    "·": "%C2%B7",
    "¸": "%C2%B8",
    "¹": "%C2%B9",
    "º": "%C2%BA",
    "»": "%C2%BB",
    "¼": "%C2%BC",
    "½": "%C2%BD",
    "¾": "%C2%BE",
    "¿": "%C2%BF",
    "À": "%C3%80",
    "Á": "%C3%81",
    "Â": "%C3%82",
    "Ã": "%C3%83",
    "Ä": "%C3%84",
    "Å": "%C3%85",
    "Æ": "%C3%86",
    "Ç": "%C3%87",
    "È": "%C3%88",
    "É": "%C3%89",
    "Ê": "%C3%8A",
    "Ë": "%C3%8B",
    "Ì": "%C3%8C",
    "Í": "%C3%8D",
    "Î": "%C3%8E",
    "Ï": "%C3%8F",
    "Ð": "%C3%90",
    "Ñ": "%C3%91",
    "Ò": "%C3%92",
    "Ó": "%C3%93",
    "Ô": "%C3%94",
    "Õ": "%C3%95",
    "Ö": "%C3%96",
    "×": "%C3%97",
    "Ø": "%C3%98",
    "Ù": "%C3%99",
    "Ú": "%C3%9A",
    "Û": "%C3%9B",
    "Ü": "%C3%9C",
    "Ý": "%C3%9D",
    "Þ": "%C3%9E",
    "ß": "%C3%9F",
    "à": "%C3%A0",
    "á": "%C3%A1",
    "â": "%C3%A2",
    "ã": "%C3%A3",
    "ä": "%C3%A4",
    "å": "%C3%A5",
    "æ": "%C3%A6",
    "ç": "%C3%A7",
    "è": "%C3%A8",
    "é": "%C3%A9",
    "ê": "%C3%AA",
    "ë": "%C3%AB",
    "ì": "%C3%AC",
    "í": "%C3%AD",
    "î": "%C3%AE",
    "ï": "%C3%AF",
    "ð": "%C3%B0",
    "ñ": "%C3%B1",
    "ò": "%C3%B2",
    "ó": "%C3%B3",
    "ô": "%C3%B4",
    "õ": "%C3%B5",
    "ö": "%C3%B6",
    "÷": "%C3%B7",
    "ø": "%C3%B8",
    "ù": "%C3%B9",
    "ú": "%C3%BA",
    "û": "%C3%BB",
    "ü": "%C3%BC",
    "ý": "%C3%BD",
    "þ": "%C3%BE",
    "ÿ": "%C3%BF",
]

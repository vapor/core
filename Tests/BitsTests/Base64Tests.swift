import XCTest
@testable import Bits

final class Base64Tests: XCTestCase {
	private func checkEncodeDecode(coder: Base64, hasPadding: Bool = true) {
		var rawData = Data()
		for currentLength in 0...256 {
			// Tests [], [0], [0, 1], etc., all the way up to [0, 1, ..., 255].
			let encoded = rawData.base64Encoded(coder)
			if hasPadding {
				XCTAssertEqual(encoded.count, Int(ceil(Double(rawData.count) / 3) * 4))
			} else {
				XCTAssertEqual(encoded.count, Int(ceil(Double(rawData.count * 4) / 3)))
			}
			
			if coder === Base64.regular {
				// Compare with the results from Foundation's Base64 coder
				XCTAssertEqual(encoded, rawData.base64EncodedString())
				XCTAssertEqual(Data(base64Encoded: encoded)!, rawData)
			}
			XCTAssertEqual(try encoded.base64Decoded(coder), rawData)
			if currentLength <= 255 {
				rawData.append(UInt8(currentLength))
			}
		}
	}
	
	func testEncodeDecodeRegular() {
		checkEncodeDecode(coder: .regular)
	}
	
	func testEncodeDecodeNoPadding() {
		checkEncodeDecode(coder: Base64(padding: nil, encodeMap: nil, decodeMap: nil), hasPadding: false)
	}
	
	func testEncodeDecodeURL() {
		checkEncodeDecode(coder: .url, hasPadding: false)
	}
	
	func testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone1() {
		var encoded = "AA=="
		XCTAssertEqual(try encoded.base64Decoded(.regular), Data(bytes: [0]))
		encoded.removeLast()
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
		encoded.removeLast()
		// This is actually more lenient than the Foundation encoder, which doesn't support missing padding at all.
		XCTAssertEqual(try encoded.base64Decoded(.regular), Data(bytes: [0]))
		encoded.removeLast()
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
		encoded.removeLast()
		XCTAssertEqual(try encoded.base64Decoded(.regular), Data())
	}
	
	func testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone2() {
		var encoded = "AAA="
		XCTAssertEqual(try encoded.base64Decoded(.regular), Data(bytes: [0, 0]))
		encoded.removeLast()
		XCTAssertEqual(try encoded.base64Decoded(.regular), Data(bytes: [0, 0]))
	}
	
	func testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone3() {
		var encoded = "AAAA="
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
		encoded.removeLast()
		XCTAssertEqual(try encoded.base64Decoded(.regular), Data(bytes: [0, 0, 0]))
	}
	
	func testDecodeThrowsWhenAddingUnexpectedCharactersAfterPadding() {
		let input = Data(bytes: [1, 2, 3])
		var encoded = input.base64Encoded(.regular)
		XCTAssertEqual(try encoded.base64Decoded(.regular), input)
		
		encoded.append("=")
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
		encoded.append("=")
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
		encoded.append("=")
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
		encoded.append("=")
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
	}
	
	func testDecodeThrowsWhenAddingUnexpectedCharactersAtEnd() {
		let input = Data(bytes: [1, 2, 3])
		var encoded = input.base64Encoded(.regular)
		XCTAssertEqual(try encoded.base64Decoded(.regular), input)
		
		encoded.append("A")
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
		encoded.append("A=")
		XCTAssertThrowsError(try encoded.base64Decoded(.regular))
	}
	
	func testDecodeThrowsWhenAddingUnexpectedPadding() {
		let input = Data(bytes: [1, 2, 3])
		var encoded = input.base64Encoded(.url)
		XCTAssertEqual(try encoded.base64Decoded(.url), input)
		
		encoded.append("A")
		XCTAssertThrowsError(try encoded.base64Decoded(.url))
		encoded.removeLast()
		encoded.append("=")
		XCTAssertThrowsError(try encoded.base64Decoded(.url))
		encoded.append("A=")
		XCTAssertThrowsError(try encoded.base64Decoded(.url))
	}
	
	static let allTests = [
		("testEncodeDecodeRegular", testEncodeDecodeRegular),
		("testEncodeDecodeNoPadding", testEncodeDecodeNoPadding),
		("testEncodeDecodeURL", testEncodeDecodeURL),
		("testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone1", testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone1),
		("testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone2", testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone2),
		("testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone3", testDecoderWithPaddingExpectsCorrectAmountOfPaddingOrNone3),
		("testDecodeThrowsWhenAddingUnexpectedCharactersAfterPadding", testDecodeThrowsWhenAddingUnexpectedCharactersAfterPadding),
		("testDecodeThrowsWhenAddingUnexpectedCharactersAtEnd", testDecodeThrowsWhenAddingUnexpectedCharactersAtEnd),
		("testDecodeThrowsWhenAddingUnexpectedPadding", testDecodeThrowsWhenAddingUnexpectedPadding),
		]
}

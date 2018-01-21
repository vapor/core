import XCTest
import Foundation
@testable import CodableKit

class KeyStringDecoderTests: XCTestCase {
    static let allTests = [
        ("testKeyStringDecodableEnum", testKeyStringDecodableEnum),
    ]
    
    func testKeyStringDecodableEnum() throws {
        let expectedPath: [CodingKey] = [CleanWrapperStructure.desiredCodingKey, CleanNestedWrapperStructure.desiredCodingKey]
        let actualPath = CleanWrapperStructure.codingPath(forKey: \CleanWrapperStructure.wrapping.areYouOfferingMeAJob)
        
        XCTAssertEqual(actualPath.count, expectedPath.count)
        actualPath.enumerated().forEach {
            XCTAssertEqual($0.element.stringValue, expectedPath[$0.offset].stringValue)
        }
        
        // Uncomment to test that Swift crashes as expected.
        // Commented by default because XCTest has no means to trap a fatalError()
        // This is in turn because fatalError() fires an undefined opcode, which
        // it's not really possible to safely trap.
        //let _ = SorryMessWrapperStructure.codingPath(forKey: \SorryMessWrapperStructure.wrapping.youHaveAlwaysBeenHere)
    }
}

// - MARK: Success fixtures

enum GoodKeypathedEnum: String, Codable, KeyStringDecodable {
    case hello, goodbye, allAlongTheWatchtower
    
    static var keyStringTrue: GoodKeypathedEnum { return .hello }
    static var keyStringFalse: GoodKeypathedEnum { return .goodbye }
}

struct CleanNestedWrapperStructure: Codable {

    static var desiredCodingKey: CodingKey { return CleanNestedWrapperStructure.CodingKeys.areYouOfferingMeAJob }

    let areYouOfferingMeAJob: GoodKeypathedEnum
    
}

struct CleanWrapperStructure: Codable {
    
    static var desiredCodingKey: CodingKey { return CleanWrapperStructure.CodingKeys.wrapping }

    let wrapping: CleanNestedWrapperStructure

}

// - MARK: Failure fixtures

enum BadKeypathedEnum: String, Codable {
    case olleh, eybdoog, onlyChildrenCanKnowMyName
}

struct SorryMessNestedWrapperStructure: Codable {

    static var desiredCodingKey: CodingKey { return SorryMessNestedWrapperStructure.CodingKeys.youHaveAlwaysBeenHere }

    let youHaveAlwaysBeenHere: BadKeypathedEnum

}

struct SorryMessWrapperStructure: Codable {

    static var desiredCodingKey: CodingKey { return SorryMessWrapperStructure.CodingKeys.wrapping }

    let wrapping: SorryMessNestedWrapperStructure
    
}


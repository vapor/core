import Foundation

public protocol URLEncodable: Encodable { }

public typealias URLCodable = URLEncodable & URLDecodable

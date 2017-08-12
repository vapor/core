import Foundation

public protocol URLEncodable: Encodable { }
public protocol URLDecodable: Decodable { }

public typealias URLCodable = URLEncodable & URLDecodable

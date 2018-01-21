import Foundation

/// Maps KeyPath to [CodingKey] on Decodable types.
extension Decodable {
    /// Returns the Decodable coding path `[CodingKey]` for the supplied key path.
    /// Note: Attempting to resolve a keyPath for non-decoded key paths (i.e., count, etc)
    /// will result in a fatalError.
    public static func codingPath<T>(forKey keyPath: KeyPath<Self, T>) -> [CodingKey] {
        var depth = 0
        a: while true {
            defer { depth += 1 }
            var progress = 0

            if depth > 42 {
                fatalError("Exceeded maximum `codingPath(forKey:)` depth.")
            }

            b: while true {
                defer { progress += 1 }
                let result = KeyStringDecoderResult(progress: progress, depth: depth)
                let decoder = KeyStringDecoder(codingPath: [], result: result)

                let decoded: Self
                do {
                    decoded = try Self(from: decoder)
                } catch {
                    unsupported(Self.self)
                }
                guard let codingPath = result.codingPath else {
                    // no more values are being set at this depth
                    break b
                }

                if isTruthy(decoded[keyPath: keyPath]) {
                    return codingPath
                }
            }
        }
    }
}

// MARK: Utils

private func isTruthy<T>(_ any: T) -> Bool {
    guard let custom = T.self as? AnyKeyStringDecodable.Type else {
        unsupported(T.self)
    }
    return custom._keyStringIsTrue(any)
}

extension Optional: AnyKeyStringDecodable {
    public static var _keyStringTrue: Any {
        guard let type = Wrapped.self as? AnyKeyStringDecodable.Type else {
            unsupported(Wrapped.self)
        }
        return type._keyStringTrue
    }

    public static var _keyStringFalse: Any {
        guard let type = Wrapped.self as? AnyKeyStringDecodable.Type else {
            unsupported(Wrapped.self)
        }
        return type._keyStringFalse
    }

    public static func _keyStringIsTrue(_ any: Any) -> Bool {
        guard let type = Wrapped.self as? AnyKeyStringDecodable.Type else {
            unsupported(Wrapped.self)
        }

        if let wrapped = any as? Wrapped {
            return type._keyStringIsTrue(wrapped)
        } else {
            return false
        }
    }
}

extension Array: AnyKeyStringDecodable {
    public static var _keyStringTrue: Any {
        guard let type = Element.self as? AnyKeyStringDecodable.Type else {
            unsupported(Element.self)
        }
        return [type._keyStringTrue]
    }

    public static var _keyStringFalse: Any {
        guard let type = Element.self as? AnyKeyStringDecodable.Type else {
            unsupported(Element.self)
        }
        return [type._keyStringFalse]
    }

    public static func _keyStringIsTrue(_ any: Any) -> Bool {
        guard let type = Element.self as? AnyKeyStringDecodable.Type else {
            unsupported(Element.self)
        }
        return type._keyStringIsTrue(any)
    }
}

extension Int: KeyStringDecodable {
    public static var keyStringTrue: Int {
        return 1
    }

    public static var keyStringFalse: Int {
        return 0
    }
}

extension Data: KeyStringDecodable {
    public static var keyStringTrue: Data {
        return Data([0x01])
    }

    public static var keyStringFalse: Data {
        return Data([0x00])
    }
}

extension String: KeyStringDecodable {
    public static var keyStringTrue: String {
        return "1"
    }

    public static var keyStringFalse: String {
        return "0"
    }
}

// MARK: Protocols

public protocol AnyKeyStringDecodable {
    static var _keyStringTrue: Any { get }
    static var _keyStringFalse: Any { get }
    static func _keyStringIsTrue(_ any: Any) -> Bool
}

public protocol KeyStringDecodable: Equatable, AnyKeyStringDecodable {
    static var keyStringTrue: Self { get }
    static var keyStringFalse: Self { get }
}

extension KeyStringDecodable {
    public static var _keyStringTrue: Any { return keyStringTrue }
    public static var _keyStringFalse: Any { return keyStringFalse }
    public static func _keyStringIsTrue(_ any: Any) -> Bool {
        return keyStringTrue == any as! Self
    }
}

private let _false = UUID()
private let _true = UUID()

/// See `KeyStringDecodable`
extension UUID: KeyStringDecodable {
    /// See `KeyStringDecodable.keyStringTrue`
    public static var keyStringTrue: UUID {
        return _true
    }

    /// See `KeyStringDecodable.keyStringFalse`
    public static var keyStringFalse: UUID {
        return _false
    }
}

private let _falsedate = Date(timeIntervalSince1970: 0)
private let _truedate = Date(timeIntervalSince1970: 1)

extension Date: KeyStringDecodable {
    public static var keyStringTrue: Date { return _truedate }
    public static var keyStringFalse: Date { return _falsedate }
}

// MARK: Result

fileprivate final class KeyStringDecoderResult {
    var codingPath: [CodingKey]?
    var progress: Int
    var current: Int
    var depth: Int
    var cycle: Bool {
        defer { current += 1 }
        return current == progress
    }

    init(progress: Int, depth: Int) {
        codingPath = nil
        current = 0
        self.depth = depth
        self.progress = progress
    }
}

// MARK: Coders

fileprivate final class KeyStringDecoder: Decoder {
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult
    var userInfo: [CodingUserInfoKey: Any]

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
        userInfo = [:]
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = KeyStringKeyedDecoder<Key>(codingPath: codingPath, result: result)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return KeyStringUnkeyedDecoder(codingPath: codingPath, result: result)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return KeyStringSingleValueDecoder(codingPath: codingPath, result: result)
    }
}

fileprivate struct KeyStringSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        if result.cycle {
            result.codingPath = codingPath
            return true
        }
        return false
    }

    func decode(_ type: Int.Type) throws -> Int {
        if result.cycle {
            result.codingPath = codingPath
            return 1
        }
        return 0
    }

    func decode(_ type: Double.Type) throws -> Double {
        if result.cycle {
            result.codingPath = codingPath
            return 1
        }
        return 0
    }

    func decode(_ type: String.Type) throws -> String {
        if result.cycle {
            result.codingPath = codingPath
            return "1"
        }
        return "0"
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = KeyStringDecoder(codingPath: codingPath, result: result)
        do {
            return try T(from: decoder)
        } catch {
            unsupported(T.self)
        }
    }
}

fileprivate struct KeyStringKeyedDecoder<K>: KeyedDecodingContainerProtocol where K: CodingKey {
    typealias Key = K
    var allKeys: [K]
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
        self.allKeys = []
    }

    func contains(_ key: K) -> Bool {
        return true
    }

    func decodeNil(forKey key: K) throws -> Bool {
        if result.depth > codingPath.count {
            return false
        }
        return true
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        let container = KeyStringKeyedDecoder<NestedKey>(codingPath: codingPath + [key], result: result)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        return KeyStringDecoder(codingPath: codingPath, result: result)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        return KeyStringDecoder(codingPath: codingPath + [key], result: result)
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        if result.cycle {
            result.codingPath = codingPath + [key]
            return true
        }
        return false
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        if result.cycle {
            result.codingPath = codingPath + [key]
            return 1
        }
        return 0
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        if result.cycle {
            result.codingPath = codingPath + [key]
            return 1
        }
        return 0
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        if result.cycle {
            result.codingPath = codingPath + [key]
            return "1"
        }
        return "0"
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        // restore query field map, for override
        if let custom = T.self as? AnyKeyStringDecodable.Type {
            if result.cycle {
                result.codingPath = codingPath + [key]
                return custom._keyStringTrue as! T
            } else {
                return custom._keyStringFalse as! T
            }
        } else {
            let decoder = KeyStringDecoder(codingPath: codingPath + [key], result: result)
            do {
                return try T(from: decoder)
            } catch {
                unsupported(T.self)
            }
        }
    }
}

fileprivate struct KeyStringUnkeyedDecoder: UnkeyedDecodingContainer {
    var count: Int?
    var isAtEnd: Bool
    var currentIndex: Int
    var codingPath: [CodingKey]
    var result: KeyStringDecoderResult

    init(codingPath: [CodingKey], result: KeyStringDecoderResult) {
        self.codingPath = codingPath
        self.result = result
        self.currentIndex = 0
        if result.cycle {
            self.count = 1
            self.isAtEnd = false
            result.codingPath = codingPath
        } else {
            self.count = 0
            self.isAtEnd = true
        }
    }

    mutating func decodeNil() throws -> Bool {
        isAtEnd = true
        return true
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        isAtEnd = true
        return true
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        isAtEnd = true
        return 1
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        isAtEnd = true
        return 1.0
    }

    mutating func decode(_ type: String.Type) throws -> String {
        isAtEnd = true
        return "1"
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        isAtEnd = true
        let decoder = KeyStringDecoder(codingPath: codingPath, result: result)
        do {
            return try T(from: decoder)
        } catch {
            unsupported(T.self)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = KeyStringKeyedDecoder<NestedKey>(codingPath: codingPath, result: result)
        return .init(container)
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return KeyStringUnkeyedDecoder(codingPath: codingPath, result: result)
    }

    mutating func superDecoder() throws -> Decoder {
        return KeyStringDecoder(codingPath: codingPath, result: result)
    }
}

private func unsupported<T>(_ type: T.Type) -> Never {
    fatalError("""
    Unknown type encountered while generating `[CodingKey]` path for a `KeyPath`.

    Please conform `\(T.self) to `KeyStringDecodable` to fix this error:

    /// See `KeyStringDecodable`
    extension \(T.self): KeyStringDecodable {
        /// See `KeyStringDecodable.keyStringTrue`
        public static var keyStringTrue: \(T.self) {
            return <#truth_value#>
        }

        /// See `KeyStringDecodable.keyStringFalse`
        public static var keyStringFalse: \(T.self) {
            return <#false_value#>
        }
    }
               
               
    See https://docs.vapor.codes/3.0/fluent/models/ for more information.
    """)
}

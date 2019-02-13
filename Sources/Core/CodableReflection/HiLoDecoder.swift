// MARK: Internal

/// Decodes types as either "hi" or "lo" signal.
struct HiLoDecoder<Root, Value>: Decoder {
    enum Signal { case hi, lo }
    
    private let ctx: Context
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any] = [:]
    
    init(signal: Signal) {
        self.init(.init(signal: signal), codingPath: [])
    }
    
    var properties: [ReflectedProperty] {
        return ctx.properties
    }
    
    private init(_ ctx: Context, codingPath: [CodingKey]) {
        self.ctx = ctx
        self.codingPath = codingPath
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
       return try singleValueContainer().decode(T.self)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return .init(KeyedDecoder(ctx, codingPath: codingPath))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return UnkeyedDecoder(ctx, codingPath: codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueDecoder(ctx, codingPath: codingPath)
    }
    
    // MARK: Private
    
    private final class Context {
        let signal: Signal
        var properties: [ReflectedProperty]
        var nextIsOptional: Bool
        init(signal: Signal) {
            self.signal = signal
            self.properties = []
            nextIsOptional = false
        }
        
        func add<T>(_ type: T.Type, at codingPath: [CodingKey]) {
            let property: ReflectedProperty
            let path = codingPath.map { $0.stringValue }
            if nextIsOptional {
                nextIsOptional = false
                property = .init(T?.self, at: path)
            } else {
                property = .init(T.self, at: path)
            }
            properties.append(property)
        }
    }
    
    private struct KeyedDecoder<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
        let allKeys: [Key] = []
        let ctx: Context
        let codingPath: [CodingKey]
        
        init(_ ctx: Context, codingPath: [CodingKey]) {
            self.ctx = ctx
            self.codingPath = codingPath
        }
        
        func contains(_ key: Key) -> Bool {
            ctx.nextIsOptional = true
            return true
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            ctx.nextIsOptional = true
            return false
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            return try SingleValueDecoder(ctx, codingPath: codingPath + [key]).decode(T.self)
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return .init(KeyedDecoder<NestedKey>(ctx, codingPath: codingPath + [key]))
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            return UnkeyedDecoder(ctx, codingPath: codingPath + [key])
        }
        
        func superDecoder() throws -> Decoder {
            return HiLoDecoder(ctx, codingPath: codingPath)
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            return HiLoDecoder(ctx, codingPath: codingPath + [key])
        }
    }
    
    private struct UnkeyedDecoder: UnkeyedDecodingContainer {
        var count: Int?
        var isAtEnd: Bool
        var currentIndex: Int
        var key: CodingKey {
            return StringCodingKey(currentIndex.description)
        }
        let ctx: Context
        let codingPath: [CodingKey]
        
        init(_ ctx: Context, codingPath: [CodingKey]) {
            self.ctx = ctx
            self.codingPath = codingPath
            self.isAtEnd = false
            self.currentIndex = 0
        }
        
        mutating func decodeNil() throws -> Bool {
            ctx.nextIsOptional = true
            return false
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            isAtEnd = true
            return try SingleValueDecoder(ctx, codingPath: codingPath + [key]).decode(T.self)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return .init(KeyedDecoder<NestedKey>(ctx, codingPath: codingPath + [key]))
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            return UnkeyedDecoder(ctx, codingPath: codingPath + [key])
        }
        
        mutating func superDecoder() throws -> Decoder {
            return HiLoDecoder(ctx, codingPath: codingPath + [key])
        }
    }
    
    private struct SingleValueDecoder: SingleValueDecodingContainer {
        let ctx: Context
        let codingPath: [CodingKey]
        
        init(_ ctx: Context, codingPath: [CodingKey]) {
            self.ctx = ctx
            self.codingPath = codingPath
        }
        
        func decodeNil() -> Bool {
            ctx.nextIsOptional = true
            return false
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            ctx.add(T.self, at: codingPath)
            if let custom = T.self as? AnyReflectionDecodable.Type,
                custom.isBaseType || type is Value {
                switch ctx.signal {
                case .hi: return custom.anyReflectDecoded().1 as! T
                case .lo: return custom.anyReflectDecoded().0 as! T
                }
            } else {
                let decoder = HiLoDecoder<Root, Value>(ctx, codingPath: codingPath)
                return try T.init(from: decoder)
            }
        }
    }
}

struct HiLoDecoder: Decoder {
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
            return BasicKey(intValue: currentIndex)!
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
        
        func decode(_ type: Bool.Type) throws -> Bool {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return true
            case .lo: return false
            }
        }
        
        func decode(_ type: String.Type) throws -> String {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return "1"
            case .lo: return "0"
            }
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            ctx.add(type, at: codingPath)
            switch ctx.signal {
            case .hi: return 1
            case .lo: return 0
            }
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            if let custom = T.self as? AnyReflectionDecodable.Type {
                ctx.add(T.self, at: codingPath)
                switch ctx.signal {
                case .hi: return try custom.anyReflectDecoded().1 as! T
                case .lo: return try custom.anyReflectDecoded().0 as! T
                }
            } else {
                let decoder = HiLoDecoder(ctx, codingPath: codingPath)
                return try T.init(from: decoder)
            }
        }
    }
}

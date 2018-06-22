struct HiEncoder: Encoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any] = [:]
    private let ctx: Context
    
    var hi: [CodingKey]? {
        return ctx.hiCodingPath
    }
    
    init() {
        self.init(.init(), codingPath: [])
    }
    
    private init(_ ctx: Context, codingPath: [CodingKey]) {
        self.ctx = ctx
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return .init(KeyedEncoder(ctx, codingPath: codingPath))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedEncoder(ctx, codingPath: codingPath)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleValueEncoder(ctx,  codingPath: codingPath)
    }
    
    // MARK: Private
    
    private final class Context {
        var hiCodingPath: [CodingKey]?
        
        init() { }
        
        func hi(_ codingPath: [CodingKey]) {
            print("hi: \(codingPath)")
            assert(hiCodingPath == nil, "Multiple hi coding paths.")
            hiCodingPath = codingPath
        }
    }
    
    private struct KeyedEncoder<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
        let codingPath: [CodingKey]
        let ctx: Context
        
        init(_ ctx: Context, codingPath: [CodingKey]) {
            self.ctx = ctx
            self.codingPath = codingPath
        }
        
        mutating func encodeNil(forKey key: Key) throws {
            // ignore
        }
        
        mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            var c = SingleValueEncoder(ctx, codingPath: codingPath + [key])
            try c.encode(value)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return .init(KeyedEncoder<NestedKey>(ctx, codingPath: codingPath + [key]))
        }
        
        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            return UnkeyedEncoder(ctx, codingPath: codingPath + [key])
        }
        
        mutating func superEncoder() -> Encoder {
            return HiEncoder(ctx, codingPath: codingPath)
        }
        
        mutating func superEncoder(forKey key: Key) -> Encoder {
            return HiEncoder(ctx, codingPath: codingPath + [key])
        }
    }
    
    private struct UnkeyedEncoder: UnkeyedEncodingContainer {
        let codingPath: [CodingKey]
        let ctx: Context
        var count: Int
        
        init(_ ctx: Context, codingPath: [CodingKey]) {
            self.ctx = ctx
            self.codingPath = codingPath
            self.count = 0
        }
        
        mutating func encodeNil() throws {
            // ignore
        }
        
        mutating func encode<T>(_ value: T) throws where T: Encodable {
            var c = SingleValueEncoder(ctx, codingPath: codingPath)
            try c.encode(value)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return .init(KeyedEncoder(ctx, codingPath: codingPath))
        }
        
        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            return UnkeyedEncoder(ctx, codingPath: codingPath)
        }
        
        mutating func superEncoder() -> Encoder {
            return HiEncoder(ctx, codingPath: codingPath)
        }
        
        
    }
    
    private struct SingleValueEncoder: SingleValueEncodingContainer {
        var codingPath: [CodingKey]
        let ctx: Context
        
        init(_ ctx: Context, codingPath: [CodingKey]) {
            self.ctx = ctx
            self.codingPath = codingPath
        }
        
        mutating func encodeNil() throws {
            // ignore
        }
        
        mutating func encode(_ value: Bool) throws {
            switch value {
            case true: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: String) throws {
            switch value {
            case "1": ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: Double) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: Float) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: Int) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: Int8) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: Int16) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: Int32) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: Int64) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: UInt) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: UInt8) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: UInt16) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: UInt32) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode(_ value: UInt64) throws {
            switch value {
            case 1: ctx.hi(codingPath)
            default: break
            }
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            if let custom = T.self as? AnyReflectionDecodable.Type {
                if try !custom.anyReflectDecodedIsLeft(value) {
                    ctx.hi(codingPath)
                }
            } else {
                let encoder = HiEncoder(ctx, codingPath: codingPath)
                return try value.encode(to: encoder)
            }
        }
    }
}

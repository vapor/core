import Core

extension Decodable {
    @available(*, deprecated, renamed: "property(forKey:)")
    public static func codingPath<T>(forKey keyPath: KeyPath<Self, T>) throws -> [CodingKey] {
        return try decodeProperty(forKey: keyPath).path.map { BasicKey($0) }
    }

    @available(*, deprecated, renamed: "properties(depth:)")
    public static func properties() throws -> [CodingKeyProperty] {
        return try decodeProperties(depth: 1).map { .init($0) }
    }
}

@available(*, deprecated, renamed: "CodableProperty")
public struct CodingKeyProperty {
    public var type: Any.Type {
        if let o = _p.type as? AnyOptionalType.Type {
            return o.anyWrappedType
        } else {
            return _p.type
        }
    }

    public var isOptional: Bool {
        return _p.type is AnyOptionalType.Type
    }

    public var codingPath: [CodingKey] {
        return _p.path.map { BasicKey($0) }
    }

    private let _p: ReflectedProperty

    init(_ p: ReflectedProperty) {
        _p = p
    }
}

@available(*, deprecated, renamed: "LosslessStringConvertible")
public protocol StringDecodable: LosslessStringConvertible {
    static func decode(from: String) -> Self?
}

extension UUID: LosslessStringConvertible {
    public init?(_ string: String) {
        self.init(uuidString: string)
    }
}

/// Capable of producing all `CodableProperty`s and converting key-path's to `CodableProperty`s.
public protocol CodableProperties {
    /// Return's all of this type's properties.
    /// - parameter depth: Controls how deeply nested optional decoding will go.
    static func properties(depth: Int) throws -> [CodableProperty]

    /// Returns the Decodable coding path `CodableProperty` for the supplied key path.
    static func property<T>(forKey keyPath: KeyPath<Self, T>) throws -> CodableProperty
}

extension Decodable {
    @available(*, deprecated, renamed: "property(forKey:)")
    public static func codingPath<T>(forKey keyPath: KeyPath<Self, T>) throws -> [CodingKey] {
        return try decodeProperty(forKey: keyPath).path.map { BasicKey($0) }
    }
}

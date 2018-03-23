/// A type that can be represented as Data in a lossless, unambiguous way.
public protocol LosslessDataConvertible {
    /// Losslessly converts this type to `Data`.
    func convertToData() throws -> Data

    /// Losslessly converts `Data` to this type.
    static func convertFromData(_ data: Data) throws -> Self
}

extension String: LosslessDataConvertible {
    /// Converts this `String` to data using `.utf8`.
    public func convertToData() -> Data {
        return Data(utf8)
    }

    /// Converts `Data` to a `utf8` encoded String.
    ///
    /// - throws: Error if String is not UTF8 encoded.
    public static func convertFromData(_ data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw CoreError(identifier: "stringData", reason: "String not UTF-8 encoded")
        }
        return string
    }
}

extension Array: LosslessDataConvertible where Element == UInt8 {
    /// Converts this `[UInt8]` to `Data`.
    public func convertToData() -> Data {
        return Data(bytes: self)
    }

    /// Converts `Data` to `[UInt8]`.
    public static func convertFromData(_ data: Data) -> Array<UInt8> {
        return .init(data)
    }
}

extension Data: LosslessDataConvertible {
    /// `LosslessDataConvertible` conformance.
    public func convertToData() throws -> Data {
        return self
    }

    /// `LosslessDataConvertible` conformance.
    public static func convertFromData(_ data: Data) -> Data {
        return data
    }
}

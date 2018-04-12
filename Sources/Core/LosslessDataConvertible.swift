/// A type that can be represented as `Data` in a lossless, unambiguous way.
public protocol LosslessDataConvertible {
    /// Losslessly converts this type to `Data`.
    func convertToData() -> Data

    /// Losslessly converts `Data` to this type.
    static func convertFromData(_ data: Data) -> Self
}

extension Data {
    /// Converts this `Data` to a `LosslessDataConvertible` type.
    ///
    ///     let string = Data([0x68, 0x69]).convert(to: String.self)
    ///     print(string) // "hi"
    ///
    /// - parameters:
    ///     - type: The `LosslessDataConvertible` to convert to.
    /// - returns: Instance of the `LosslessDataConvertible` type.
    public func convert<T>(to type: T.Type = T.self) -> T where T: LosslessDataConvertible {
        return T.convertFromData(self)
    }
}

extension String: LosslessDataConvertible {
    /// Converts this `String` to data using `.utf8`.
    public func convertToData() -> Data {
        return Data(utf8)
    }

    /// Converts `Data` to a `utf8` encoded String.
    ///
    /// - throws: Error if String is not UTF8 encoded.
    public static func convertFromData(_ data: Data) -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            /// FIXME: string convert _from_ data is not actually lossless.
            /// this should really only conform to a `LosslessDataRepresentable` protocol.
            return ""
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
    public func convertToData() -> Data {
        return self
    }

    /// `LosslessDataConvertible` conformance.
    public static func convertFromData(_ data: Data) -> Data {
        return data
    }
}

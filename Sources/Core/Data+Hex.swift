import Bits

extension Data {
    /// Converts `Data` to a hex-encoded `String`.
    ///
    ///     Data("hello".utf8).hexEncodedString() // 68656c6c6f
    ///
    /// - parameters:
    ///     - uppercase: If `true`, uppercase letters will be used when encoding.
    ///                  Default value is `false`.
    public func hexEncodedString(uppercase: Bool = false) -> String {
        return String(bytes: hexEncodedData(uppercase: uppercase), encoding: .utf8) ?? ""
    }


    /// Applies hex-encoding to `Data`.
    ///
    ///     Data("hello".utf8).hexEncodedData() // 68656c6c6f
    ///
    /// - parameters:
    ///     - uppercase: If `true`, uppercase letters will be used when encoding.
    ///                  Default value is `false`.
    public func hexEncodedData(uppercase: Bool = false) -> Data {
        var bytes = Data()
        bytes.reserveCapacity(count * 2)

        let table: Bytes
        if uppercase {
            table = radix16table_uppercase
        } else {
            table = radix16table_lowercase
        }

        for byte in self {
            bytes.append(table[Int(byte / 16)])
            bytes.append(table[Int(byte % 16)])
        }

        return bytes
    }
}

/// Uppercase radix16 table.
fileprivate let radix16table_uppercase: Bytes = [
    .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .A, .B, .C, .D, .E, .F
]

/// Lowercase radix16 table.
fileprivate let radix16table_lowercase: Bytes = [
    .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .a, .b, .c, .d, .e, .f
]

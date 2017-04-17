extension Sequence where Iterator.Element == Byte {
    @available(*, deprecated: 1.1, message: "Use `Bytes.base64Encoded.string` instead.")
    public var base64String: String {
        return base64Encoded.string
    }
    
    @available(*, deprecated: 1.1, message: "Use `Bytes.base64Encoded` instead.")
    public var base64Data: Bytes {
        return base64Encoded
    }
    
    public var base64Encoded: Bytes {
        let bytes = [Byte](self)
        return Base64Encoder.shared.encode(bytes)
    }
    
    public var base64Decoded: Bytes {
        let bytes = [Byte](self)
        return Base64Encoder.shared.decode(bytes)
    }
}

extension String {
    @available(*, deprecated: 1.1, message: "Use `String.bytes.base64Decoded.string` instead.")
    public var base64DecodedString: String {
        return bytes.base64Decoded.string
    }
}

import Foundation

extension Sequence where Iterator.Element == Byte {
    @available(*, deprecated: 1.1, message: "Use `Bytes.base64Encoded.string` instead.")
    public var base64String: String {
        let bytes = [Byte](self)
        let data = Data(bytes: bytes)

        return data.base64EncodedString()
    }
    
    @available(*, deprecated: 1.1, message: "Use `Bytes.base64Encoded` instead.")
    public var base64Data: Bytes {
        let bytes = [Byte](self)
        let data = Data(bytes: bytes)

        let encodedData = data.base64EncodedData()

        var encodedBytes = Bytes(repeating: 0, count: encodedData.count)
        encodedData.copyBytes(to: &encodedBytes, count: encodedData.count)

        return encodedBytes
    }
    
    public var base64Encoded: Bytes {
        let bytes = [Byte](self)
        let data = Data(bytes: bytes)
        
        let encodedData = data.base64EncodedData()
        
        var encodedBytes = Bytes(repeating: 0, count: encodedData.count)
        encodedData.copyBytes(to: &encodedBytes, count: encodedData.count)
        
        return encodedBytes
    }
    
    public var base64Decoded: Bytes {
        let bytes = [Byte](self)
        let dataBase64 = Data(bytes: bytes)
        guard let dataDecoded = Data(base64Encoded: dataBase64, options: .ignoreUnknownCharacters) else {
            return []
        }
        
        var decodedBytes = Bytes(repeating: 0, count: dataDecoded.count)
        dataDecoded.copyBytes(to: &decodedBytes, count: dataDecoded.count)
        
        return decodedBytes
    }
}

extension String {
    @available(*, deprecated: 1.1, message: "Use `String.bytes.base64Decoded.string` instead.")
    public var base64DecodedString: String {
        guard let data = NSData(base64Encoded: self, options: []) else { return "" }
        var bytes = Bytes(repeating: 0, count: data.length)
        data.getBytes(&bytes,  length: data.length)
        return bytes.string
    }
}

import Foundation

extension Sequence where Iterator.Element == Byte {
    public var base64String: String {
        let bytes = [Byte](self)
        let data = Data(bytes: bytes)

        return data.base64EncodedString()
    }

    public var base64Data: Bytes {
        let bytes = [Byte](self)
        let data = Data(bytes: bytes)

        let encodedData = data.base64EncodedData()

        var encodedBytes = Bytes(repeating: 0, count: encodedData.count)
        encodedData.copyBytes(to: &encodedBytes, count: encodedData.count)

        return encodedBytes
    }
}

extension String {
    public var base64DecodedString: String {
        guard let data = NSData(base64Encoded: self, options: []) else { return "" }
        var bytes = Bytes(repeating: 0, count: data.length)
        data.getBytes(&bytes,  length: data.length)
        return bytes.string
    }
}

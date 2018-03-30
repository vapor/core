import Foundation

extension Data {
    /// Returns a `0x` prefixed, space-separated, hex-encoded string for this `Data`.
    public var hexDebug: String {
        return "0x" + map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

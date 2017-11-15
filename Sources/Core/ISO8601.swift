import Foundation

public struct ISO8601 {
    public static let shared = ISO8601()
    public let formatter: DateFormatter
    
    public init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        self.formatter = formatter
    }
}

extension Date {
    public var iso8601: String {
        return ISO8601.shared.formatter.string(from: self)
    }
    
    public init?(iso8601: String) {
        guard let date = ISO8601.shared.formatter.date(from: iso8601) else {
            return nil
        }
        
        self = date
    }
}

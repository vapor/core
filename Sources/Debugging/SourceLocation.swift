public struct SourceLocation {
    var file: String
    var function: String
    var line: UInt
    var column: UInt
    var range: Range<UInt>?
}

/// Types conforming to extendable can have stored
/// properties added in extension by using the
/// provided dictionary.
public protocol Extendable: class {
    var extend: [String: Any] { get set }
}

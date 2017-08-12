/// Types conforming to Polymorphic can be
/// easily converted to common Standard Library types.
public protocol Polymorphic {
    var string: String? { get }
    var int: Int? { get }
    var uint: UInt? { get }
    var double: Double? { get }
    var bool: Bool? { get }
    var dictionary: [String: Self]? { get }
    var array: [Self]? { get }
    var isNull: Bool { get }
}

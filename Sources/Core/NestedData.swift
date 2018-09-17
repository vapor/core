/// A data structure containing arbitrarily nested arrays and dictionaries.
///
/// Conforming to this protocol adds two methods to the conforming type for getting and
/// setting the nested data.
///
/// - `NestedData.get(at:)`
/// - `NestedData.set(to:at:)`
///
public protocol NestedData {
    /// Returns a dictionary representation of `self`, or `nil` if not possible.
    var dictionary: [String: Self]? { get }

    /// Returns an array representation of self, or `nil` if not possible.
    var array: [Self]? { get }

    /// Creates `self` from a dictionary representation.
    static func dictionary(_ value: [String: Self]) -> Self

    /// Creates `self` from an array representation.
    static func array(_ value: [Self]) -> Self
}

extension NestedData {
    /// Sets self to the supplied value at a given path.
    ///
    ///     data.set(to: "hello", at: ["path", "to", "value"])
    ///
    /// - parameters:
    ///     - value: Value of `Self` to set at the supplied path.
    ///     - path: `CodingKey` path to update with the supplied value.
    public mutating func set(to value: Self, at path: [CodingKey]) {
        set(&self, to: value, at: path)
    }

    /// Sets self to the supplied value at a given path.
    ///
    ///     data.get(at: ["path", "to", "value"])
    ///
    /// - parameters:
    ///     - path: `CodingKey` path to fetch the supplied value at.
    /// - returns: An instance of `Self` if a value exists at the path, otherwise `nil`.
    public func get(at path: [CodingKey]) -> Self? {
        var child = self
        for seg in path {
            if let dictionary = child.dictionary, let c = dictionary[seg.stringValue] {
                child = c
            } else if let array = child.array, let index = seg.intValue {
                child = array[index]
            } else {
                return nil
            }
        }
        return child
    }

    /// Recursive backing method to `set(to:at:)`.
    private func set(_ context: inout Self, to value: Self, at path: [CodingKey]) {
        guard path.count >= 1 else {
            context = value
            return
        }

        let end = path[0]
        var child: Self
        switch path.count {
        case 1:
            child = value
        case 2...:
            if let index = end.intValue {
                let array = context.array ?? []
                if array.count > index {
                    child = array[index]
                } else {
                    child = .array([])
                }
                set(&child, to: value, at: Array(path[1...]))
            } else {
                child = context.dictionary?[end.stringValue] ?? .dictionary([:])
                set(&child, to: value, at: Array(path[1...]))
            }
        default: fatalError("Unreachable")
        }

        if let index = end.intValue {
            if var arr = context.array {
                if arr.count > index {
                    arr[index] = child
                } else {
                    arr.append(child)
                }
                context = .array(arr)
            } else {
                context = .array([child])
            }
        } else {
            if var dict = context.dictionary {
                dict[end.stringValue] = child
                context = .dictionary(dict)
            } else {
                context = .dictionary([end.stringValue: child])
            }
        }
    }
}

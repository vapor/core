public protocol Identifiable {
    /// A readable name for the error's Type. This is usually
    /// similar to the Type name of the error with spaces added.
    /// This will normally be printed proceeding the error's reason.
    /// - note: For example, an error named `FooError` will have the
    /// `readableName` `"Foo Error"`.
    static var readableName: String { get }

    // MARK: Identifiers

    /// A unique identifier for the error's Type.
    /// - note: This defaults to `ModuleName.TypeName`,
    /// and is used to create the `identifier` property.
    static var typeIdentifier: String { get }

    /// Some unique identifier for this specific error.
    /// This will be used to create the `identifier` property.
    /// Do NOT use `String(reflecting: self)` or `String(describing: self)`
    /// or there will be infinite recursion
    var identifier: String { get }
}

extension Identifiable {
    public var fullIdentifier: String {
        return Self.typeIdentifier + "." + identifier
    }
}

extension Identifiable {
    /// Default implementation of readable name that expands
    /// SomeModule.MyType.Error => My Type Error
    public static var readableName: String {
        return typeIdentifier
    }

    /// See `Identifiable.typeIdentifier`
    public static var typeIdentifier: String {
        let type = "\(self)"
        return type.split(separator: ".").last.flatMap(String.init) ?? type
    }
}

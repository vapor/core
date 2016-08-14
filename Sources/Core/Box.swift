/**
     Box encapsulates values in a reference type for scenarios where it is required
*/
public final class Box<T> {

    /**
         The underlying value
    */
    public let value: T

    /**
         Create a reference counted box around a value

         - parameter value: the value to box
    */
    public init(_ value: T) {
        self.value = value
    }
}

public typealias Stream = InputStream & OutputStream

public protocol InputStream: class {
    associatedtype Input
    func input(_ input: Input) throws
}

public protocol OutputStream: class {
    associatedtype Output
    typealias OutputHandler = (Output) throws -> ()
    var output: OutputHandler? { get set }
}


extension OutputStream {
    public func consume(_ handler: @escaping OutputHandler) {
        self.output = handler
    }

    public func stream<S: Stream>(to stream: S) -> S where S.Input == Self.Output {
        self.output = stream.input
        return stream
    }

    public func consume<I: InputStream>(into input: I) where I.Input == Self.Output {
        self.output = input.input
    }
}

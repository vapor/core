public typealias Stream = InputStream & OutputStream

public protocol InputStream: BaseStream {
    associatedtype Input
    func inputStream(_ input: Input)
}

public protocol OutputStream: BaseStream {
    associatedtype Output
    typealias OutputHandler = (Output) -> ()
    var outputStream: OutputHandler? { get set }
}

public protocol BaseStream: class {
    typealias ErrorHandler = (Error) -> ()
    var errorStream: ErrorHandler? { get set }
}

extension OutputStream {
    public func consume(_ handler: @escaping OutputHandler) {
        self.outputStream = handler
    }

    public func stream<S: Stream>(to stream: S) -> S where S.Input == Self.Output {
        stream.errorStream = self.errorStream
        self.outputStream = stream.inputStream
        return stream
    }

    public func consume<I: InputStream>(into input: I) where I.Input == Self.Output {
        input.errorStream = self.errorStream
        self.outputStream = input.inputStream
    }
}

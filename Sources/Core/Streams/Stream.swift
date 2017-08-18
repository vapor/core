/// A stream of generic information
public protocol Stream {
    /// The contents of this stream
    associatedtype Output
    
    /// Registers a closure that must be executed for every `Output` event
    ///
    /// - parameter closure: The closure to execute for each `Output` event
    /// - returns: A future that completes when the Output has been processed
    func then(_ closure: @escaping ((Output) throws -> (Future<Void>)))
}

extension Stream {
    public func then(_ closure: @escaping ((Output) throws -> (Void))) {
        self.then { output in
            return Future {
                try closure(output)
            }
        }
    }
    
    /// Maps this stream to a stream of other information
    ///
    /// - parameter closure: Maps `Output` to a different steam type
    /// - returns: A transformed stream
    public func map<T>(_ closure: @escaping ((Output) throws -> (T?))) -> StreamTransformer<Output, T> {
        let transformer =  StreamTransformer<Output, T>(using: closure)
        
        self.then { input in
            _ = try transformer.process(input)
        }
        
        return transformer
    }
}

open class BasicStream<Output> : Stream {
    /// Registers a closure that must be executed for every `Output` event
    ///
    /// - parameter closure: The closure to execute for each `Output` event
    public func then(_ closure: @escaping ((Output) throws -> (Future<Void>))) {
        listeners.append(closure)
    }
    
    public func write(_ output: Output) throws -> Future<Void> {
        return Future(try listeners.map { listener in
            return try listener(output)
        })
    }
    
    public init() {}
    
    /// Internal typealias used to define a cascading callback
    fileprivate typealias Listener = ((Output) throws -> (Future<Void>))
    
    /// An internal array, used to keep track of all closures waiting for more data from this stream
    fileprivate var listeners = [Listener]()
}

/// A helper that allows you to transform streams
open class StreamTransformer<From, To> : Stream {
    /// The underlying stream helper
    let stream = BasicStream<To>()
    
    /// Registers a closure that must be executed for every `Output` event
    ///
    /// - parameter closure: The closure to execute for each `Output` event
    public func then(_ closure: @escaping ((To) throws -> (Future<Void>))) {
        stream.then(closure)
    }
    
    /// The input, that's being transformed
    public typealias Input = From
    
    /// The resulting output
    public typealias Output = To
    
    /// The transformer used to achieve the transformation from the input to the output
    let transformer: ((Input) throws -> (Output?))
    
    /// Creates a new StreamTransformer using a closure
    public init(using closure: @escaping ((Input) throws -> (Output?))) {
        self.transformer = closure
    }
    
    /// Transforms the incoming data
    public func process(_ input: Input) throws {
        if let output = try transformer(input) {
            _ = try stream.write(output)
        }
    }
}


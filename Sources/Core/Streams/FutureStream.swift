extension Stream where Output : FutureType {
    public func stream<T>(to closure: @escaping (Output.Expectation) -> (T?)) -> StreamTransformer<Output.Expectation, T> {
        let transformer =  StreamTransformer<Output.Expectation, T>(using: closure)
        
        self.process { future in
            future.onComplete(asynchronously: nil) { result in
                if case .expectation(let expectation) = result {
                    _ = try? transformer.process(expectation)
                }
            }
        }
        
        return transformer
    }
}

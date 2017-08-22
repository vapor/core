extension Future {
    /// Streams the result of this future to the InputStream
    public func stream<S: InputStream>(to stream: S) where S.Input == Expectation {
        self.then(stream.inputStream)
    }
}

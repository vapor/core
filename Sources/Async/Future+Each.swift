extension Future where T: Sequence {
    
    /// Iterates over each element of a sequence in a future,
    /// running a transformation method on each element.
    /// The result returned should be a non-future type.
    func each<Wrapped>(to: Wrapped.Type, transform: @escaping (Expectation.Element)throws -> Wrapped) -> Future<[Wrapped]> {
        return self.map(to: [Wrapped].self, { (this) in
            return try this.map(transform)
        })
    }
    
    /// Iterates over each element of a sequence in a future,
    /// running a transformation method on each element.
    /// The result returned should be a future.
    func flatEach<Wrapped>(to: Wrapped.Type, transform: @escaping (Expectation.Element)throws -> Future<Wrapped>) -> Future<[Wrapped]> {
        return self.flatMap(to: [Wrapped].self, { (this) in
            return try this.map(transform).flatten(on: self.eventLoop)
        })
    }
}

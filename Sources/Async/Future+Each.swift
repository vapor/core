extension Future where T: Sequence {
    
    func each<Wrapped>(to: Wrapped.Type, transform: @escaping (Expectation.Element)throws -> Wrapped) -> Future<[Wrapped]> {
        return self.map(to: [Wrapped].self, { (this) in
            return try this.map(transform)
        })
    }
}

final class ReflectionDecoderContext {
    var codingPath: [CodingKey]?
    var depth: Int
    var properties: [ReflectedProperty]
    var nextIsOptional: Bool

    var cycle: Bool {
        defer { _current += 1 }
        return _current == _progress
    }

    private var _progress: Int
    private var _current: Int

    init(progress: Int, depth: Int) {
        self.codingPath = nil
        self.depth = depth
        self.nextIsOptional = false
        self.properties = []
        _current = 0
        self._progress = progress
    }

    func addProperty<T>(type: T.Type, at path: [CodingKey]) {
        let type: Any.Type
        if nextIsOptional {
            type = T?.self
            nextIsOptional = false
        } else {
            type = T.self
        }
        let property = ReflectedProperty.init(any: type, at: path.map { $0.stringValue })
        properties.append(property)
    }
}

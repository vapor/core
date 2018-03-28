/// This protocol allows for reflection of properties on conforming types.
///
/// Ideally Swift type mirroring would handle this completely. In the interim, this protocol
/// acts to fill in the missing gaps.
///
/// Types that conform to this protocol and are also `Decodable` will get the implementations for free
/// from the `CodableKit` module.
public protocol Reflectable {
    /// Reflects all of this type's `ReflectedProperty`s.
    static func reflectProperties() throws -> [ReflectedProperty]

    /// Returns a `ReflectedProperty` for the supplied key path.
    static func reflectProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty?
}

/// Represents a property on a type that has been reflected using the `Reflectable` protocol.
public struct ReflectedProperty {
    /// This property's type.
    public let type: Any.Type

    /// The path to this property.
    public let path: [String]

    /// Creates a new `ReflectedProperty` from a type and path.
    public init<T>(_ type: T.Type, at path: [String]) {
        self.type = T.self
        self.path = path
    }

    /// Creates a new `ReflectedProperty` using `Any.Type` and a path.
    public init(any type: Any.Type, at path: [String]) {
        self.type = type
        self.path = path
    }
}

extension ReflectedProperty: CustomStringConvertible {
    /// See CustomStringConvertible.description
    public var description: String {
        return "\(path.joined(separator: ".")): \(type)"
    }
}


//// MARK: Memory Layout
//
//extension Reflectable {
//    /// Reflects all of this type's `ReflectedProperty`s.
//    public static func reflectProperties() throws -> [ReflectedProperty] {
//        guard let metadata = metadataLayout(Self.self) else {
//            return []
//        }
//
//        var properties: [ReflectedProperty] = []
//        let types = metadata.fieldTypes
//        let names = metadata.fieldNames
//
//        for i in 0..<Int(metadata.fieldCount) {
//            let property = ReflectedProperty(any: types[i], at: [names[i]])
//            properties.append(property)
//        }
//
//        return properties
//    }
//
//    /// Returns a `ReflectedProperty` for the supplied key path.
//    public static func reflectProperty<T>(forKey keyPath: KeyPath<Self, T>) throws -> ReflectedProperty? {
//        guard let metadata = metadataLayout(Self.self) else {
//            return nil
//        }
//        let keyPathOffset = fieldOffset(for: keyPath as AnyKeyPath)
//        for (i, fieldOffset) in metadata.fieldOffsets.enumerated() {
//            if fieldOffset == keyPathOffset {
//                return try reflectProperties()[i]
//            }
//        }
//
//        return nil
//    }
//}
//
//
//
//func metadataLayout(_ type: Any.Type) -> CommonMetadataLayout? {
//    let metaTypeDescriptor = unsafeBitCast(type, to: UnsafeRawPointer.self)
//    let type = metaTypeDescriptor.assumingMemoryBound(to: Int.self).pointee
//    switch type {
//    case 1: // struct
//        return .init(
//            metaTypeDescriptor: metaTypeDescriptor,
//            nominalTypeDescriptor: metaTypeDescriptor.assumingMemoryBound(to: UnsafePointer<UnsafeRawPointer>.self).advanced(by: 1).pointee
//        )
//    case 0, 4096... /* obj-c isa pointer will be >4096, but on linux will be 0 */: // class
//        return .init(
//            metaTypeDescriptor: metaTypeDescriptor,
//            nominalTypeDescriptor: metaTypeDescriptor.assumingMemoryBound(to: UnsafePointer<UnsafeRawPointer>.self).advanced(by: 8 /*32 bits is 11 */).pointee
//        )
//    default: return nil
//    }
//}
//
//
//func fieldOffset(for keyPath: AnyKeyPath) -> Int {
//    let keyPathDescriptor = unsafeBitCast(keyPath, to: UnsafeRawPointer.self)
////    let offset = keyPathDescriptor.advanced(by: 32).assumingMemoryBound(to: Int.self).pointee & 0x00FFFFFF
////    guard offset != 0x00FFFFFF else {
////        // overflowed
////        return keyPathDescriptor.advanced(by: 40).assumingMemoryBound(to: Int.self).pointee & 0x00FFFFFF  //- 64
////    }
//    let offset = keyPathDescriptor.advanced(by: 32).assumingMemoryBound(to: UInt32.self).pointee & 0x1FFFFFFF
//    guard offset != 0x1FFFFFFF else {
//        fatalError("AnyKeyPath can not represent a field that appears more than 512GB into a type.")
//    }
//    return Int(offset)
//}
//
//func dump(_ ptr: UnsafeRawPointer, count: Int = 64) {
//    for i in 0..<count {
//        if i != 0 && i % 16 == 0 {
//            print()
//        }
//        let byte = String(format: "%02X", ptr.advanced(by: i).assumingMemoryBound(to: UInt8.self).pointee)
//        print(byte, terminator: " ")
//    }
//}
//
//typealias FieldTypeAccessor = @convention(c) (UnsafePointer<Int>) -> UnsafePointer<UnsafePointer<Int>>
//
//struct CommonMetadataLayout: CustomStringConvertible {
//    let metaTypeDescriptor: UnsafeRawPointer
//    let nominalTypeDescriptor: UnsafeRawPointer
//
//    init(metaTypeDescriptor: UnsafeRawPointer, nominalTypeDescriptor: UnsafeRawPointer) {
//        self.nominalTypeDescriptor = nominalTypeDescriptor
//        self.metaTypeDescriptor = metaTypeDescriptor
//    }
//
//    var mangledNameOffset: Int32 {
//        return nominalTypeDescriptor.assumingMemoryBound(to: Int32.self).pointee
//    }
//
//    var fieldCount: Int32 {
//        return nominalTypeDescriptor.advanced(by: 4).assumingMemoryBound(to: Int32.self).pointee
//    }
//    var fieldOffsetVectorOffset: Int32 {
//        return nominalTypeDescriptor.advanced(by: 8).assumingMemoryBound(to: Int32.self).pointee
//    }
//    var fieldNamesOffset: Int32 {
//        return nominalTypeDescriptor.advanced(by: 12).assumingMemoryBound(to: Int32.self).pointee
//    }
//    var fieldTypeAccessorOffset: Int32 {
//        return nominalTypeDescriptor.advanced(by: 16).assumingMemoryBound(to: Int32.self).pointee
//    }
//
//    var mangledName: String {
//        return String(cString: nominalTypeDescriptor.advanced(by: numericCast(mangledNameOffset)).assumingMemoryBound(to: CChar.self))
//    }
//
//    var fieldNames: [String] {
//        var fieldNames: [String] = []
//
//        var currentOffset: Int = numericCast(fieldNamesOffset)
//        while true {
//            let fieldName = String(cString: nominalTypeDescriptor.advanced(by: currentOffset + 12).assumingMemoryBound(to: CChar.self))
//            currentOffset += fieldName.count + 1 // skip null
//            fieldNames.append(fieldName)
//            if fieldNames.count >= fieldCount {
//                break
//            }
//        }
//
//        return fieldNames
//    }
//
//    var fieldTypes: [Any.Type] {
//        var types: [Any.Type] = []
//
//        let accessorReference = nominalTypeDescriptor.advanced(by: numericCast(fieldTypeAccessorOffset) + 16).assumingMemoryBound(to: Any.self)
//        let accessor = unsafeBitCast(accessorReference, to: FieldTypeAccessor.self)
//        for i in 0..<Int(fieldCount) {
//            let typeptr = accessor(metaTypeDescriptor.assumingMemoryBound(to: Int.self))
//            let type = unsafeBitCast(typeptr.advanced(by: i).pointee, to: Any.Type.self)
//            types.append(type)
//        }
//
//        return types
//    }
//
//    var fieldOffsets: [Int] {
//        var fieldOffsets: [Int] = []
//
//        var currentOffset: Int = numericCast(fieldOffsetVectorOffset)
//        while true {
//            let fieldOffset = metaTypeDescriptor.assumingMemoryBound(to: Int.self).advanced(by: currentOffset).pointee
//            currentOffset += 1
//            fieldOffsets.append(fieldOffset)
//            if fieldOffsets.count >= fieldCount {
//                break
//            }
//        }
//
//        return fieldOffsets
//    }
//
//    var description: String {
//        return """
//        \(mangledName)
//        - fieldCount: \(fieldCount)
//        - fieldTypes: \(fieldTypes)
//        - fieldNames: \(fieldNames)
//        - fieldOffsets: \(fieldOffsets)
//        - mangledNameOffset: \(mangledNameOffset)
//        - fieldOffsetVectorOffset: \(fieldOffsetVectorOffset)
//        - fieldNamesOffset: \(fieldNamesOffset)
//        - fieldTypeAccessorOffset: \(fieldTypeAccessorOffset)
//        """
//    }
//}

//
//  UTF8String.swift
//  Vapor
//
//  Created by Joannis Orlandos on 01/05/2017.
//
//

import Bits
import libc

public protocol VaporString {
    var utf8String: UTF8String { get }
    var bytes: Bytes { get }
    var string: String { get }
}

extension VaporString {
    public var string: String {
        return utf8String.string ?? ""
    }
    
    public var bytes: Bytes {
        return utf8String.bytes
    }
    
    public func lowercased() -> UTF8String {
        return utf8String.lowercased()
    }
    
    public func uppercased() -> UTF8String {
        return utf8String.uppercased()
    }
    
    public func contains(_ other: VaporString) -> Bool {
        return self.utf8String.contains(other)
    }
}

extension String : VaporString {
    public var utf8String: UTF8String {
        return UTF8String(string: self)
    }
    
    public var swiftString: String? {
        return self
    }
}

extension StaticString : VaporString, Hashable {
    public var utf8String: UTF8String {
        return UTF8String(staticString: self)
    }
    
    public var bytes: Bytes {
        var bytes = Bytes(repeating: 0, count: self.utf8CodeUnitCount)
        memcpy(&bytes, self.utf8Start, self.utf8CodeUnitCount)
        
        return bytes
    }
    
    public var hashValue: Int {
        guard self.utf8CodeUnitCount > 0 else {
            return 0
        }
        
        var h = 0
        
        for i in 0..<self.utf8CodeUnitCount {
            h = 31 &* h &+ numericCast(self.utf8Start.advanced(by: i).pointee)
        }
        
        return h
    }
    
    public static func ==(lhs: StaticString, rhs: StaticString) -> Bool {
        guard lhs.utf8CodeUnitCount == rhs.utf8CodeUnitCount else {
            return false
        }
        
        return memcmp(lhs.utf8Start, rhs.utf8Start, lhs.utf8CodeUnitCount) == 0
    }
}

public struct UTF8String : Hashable, ExpressibleByStringLiteral, Comparable, VaporString, BytesConvertible {
    public var utf8String: UTF8String {
        return self
    }
    
    public func makeBytes() throws -> Bytes {
        return bytes
    }
    
    public func lowercased() -> UTF8String {
        return UTF8String(bytes: bytes.map { byte in
            if byte > 0x60 && byte < 0x7b {
                return byte &- 0x20
            } else {
                return byte
            }
        })
    }
    
    public func uppercased() -> UTF8String {
        return UTF8String(bytes: bytes.map { byte in
            if byte > 0x40 && byte < 0x5b {
                return byte &+ 0x20
            } else {
                return byte
            }
        })
    }
    
    public var string: String? {
        return String(bytes: bytes, encoding: .utf8)
    }
    
    public func contains(_ string: VaporString) -> Bool {
        let substring = string.utf8String.bytes
        
        compareLoop: for (position, byte) in bytes.enumerated() where byte == substring.first {
            guard bytes.count > position + substring.count else {
                continue compareLoop
            }
            
            for (comparePosition, compareByte) in substring.enumerated() where bytes[position + comparePosition] != compareByte {
                continue compareLoop
            }
            
            return true
        }
        
        return false
    }
    
    public static func <(lhs: UTF8String, rhs: UTF8String) -> Bool {
        for (position, byte) in lhs.bytes.enumerated() {
            guard position < rhs.bytes.count else {
                return true
            }
            
            if byte < rhs.bytes[position] {
                return true
            }
            
            if byte > rhs.bytes[position] {
                return false
            }
        }
        
        return String(bytes: lhs.bytes, encoding: .utf8)! > String(bytes: rhs.bytes, encoding: .utf8)!
    }
    
    public static func >(lhs: UTF8String, rhs: UTF8String) -> Bool {
        for (position, byte) in lhs.bytes.enumerated() {
            guard position < rhs.bytes.count else {
                return false
            }
            
            if byte > rhs.bytes[position] {
                return true
            }
            
            if byte < rhs.bytes[position] {
                return false
            }
        }
        
        return String(bytes: lhs.bytes, encoding: .utf8)! > String(bytes: rhs.bytes, encoding: .utf8)!
    }
    
    public static func ==(lhs: UTF8String, rhs: UTF8String) -> Bool {
        return lhs.bytes == rhs.bytes
    }
    
    public var hashValue: Int {
        guard bytes.count > 0 else {
            return 0
        }
        
        var h = 0
        
        for i in 0..<bytes.count {
            h = 31 &* h &+ numericCast(bytes[i])
        }
        
        return h
    }
    
    public var lowercasedHashValue: Int {
        guard bytes.count > 0 else {
            return 0
        }
        
        var h = 0
        
        for i in 0..<bytes.count {
            if bytes[i] > 0x60 && bytes[i] < 0x7b {
                h = 31 &* h &+ numericCast(bytes[i] &- 0x20)
            } else {
                h = 31 &* h &+ numericCast(bytes[i])
            }
        }
        
        return h
    }
    
    public var uppercasedHashValue: Int {
        guard bytes.count > 0 else {
            return 0
        }
        
        var h = 0
        
        for i in 0..<bytes.count {
            if bytes[i] > 0x40 && bytes[i] < 0x5b {
                h = 31 &* h &+ numericCast(bytes[i] &+ 0x20)
            } else {
                h = 31 &* h &+ numericCast(bytes[i])
            }
        }
        
        return h
    }
    
    public var bytes: Bytes
    
    public init(bytes: Bytes) {
        self.bytes = bytes
    }
    
    public init(string: String) {
        self.bytes = Array(string.utf8)
    }
    
    public init(staticString value: StaticString) {
        bytes = value.bytes
    }
    
    public init(stringLiteral value: StaticString) {
        self.init(staticString: value)
    }
    
    public init(unicodeScalarLiteral value: StaticString) {
        self.init(staticString: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StaticString) {
        self.init(staticString: value)
    }
}

public func ==(lhs: VaporString, rhs: VaporString) -> Bool {
    return lhs.utf8String == rhs.utf8String
}

public func ==(lhs: VaporString?, rhs: VaporString) -> Bool {
    return lhs?.utf8String == rhs.utf8String
}

public func ==(lhs: VaporString, rhs: VaporString?) -> Bool {
    return lhs.utf8String == rhs?.utf8String
}

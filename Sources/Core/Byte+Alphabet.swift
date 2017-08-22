
// MARK: Alphabet

extension Byte {
    /// Returns whether or not the given byte is an arabic letter
    public var isLetter: Bool {
        return (.a ... .z).contains(self) || (.A ... .Z).contains(self)
    }

    /// Returns whether or not a given byte represents a UTF8 digit 0 through 9, or an arabic letter
    public var isAlphanumeric: Bool {
        return isLetter || isDigit
    }

    /// Returns whether a given byte can be interpreted as a hex value in UTF8, ie: 0-9, a-f, A-F.
    public var isHexDigit: Bool {
        return (.zero ... .nine).contains(self) || (.A ... .F).contains(self) || (.a ... .f).contains(self)
    }

    /// A
    static let A: Byte = 0x41

    /// B
    static let B: Byte = 0x42

    /// C
    static let C: Byte = 0x43

    /// D
    static let D: Byte = 0x44

    /// E
    static let E: Byte = 0x45

    /// F
    static let F: Byte = 0x46

    /// G
    static let G: Byte = 0x47

    /// H
    static let H: Byte = 0x48

    /// I
    static let I: Byte = 0x49

    /// J
    static let J: Byte = 0x4A

    /// K
    static let K: Byte = 0x4B

    /// L
    static let L: Byte = 0x4C

    /// M
    static let M: Byte = 0x4D

    /// N
    static let N: Byte = 0x4E

    /// O
    static let O: Byte = 0x4F

    /// P
    static let P: Byte = 0x50

    /// Q
    static let Q: Byte = 0x51

    /// R
    static let R: Byte = 0x52

    /// S
    static let S: Byte = 0x53

    /// T
    static let T: Byte = 0x54

    /// U
    static let U: Byte = 0x55

    /// V
    static let V: Byte = 0x56

    /// W
    static let W: Byte = 0x57

    /// X
    static let X: Byte = 0x58

    /// Y
    static let Y: Byte = 0x59

    /// Z
    static let Z: Byte = 0x5A
}

extension Byte {
    /// a
    static let a: Byte = 0x61

    /// b
    static let b: Byte = 0x62

    /// c
    static let c: Byte = 0x63

    /// d
    static let d: Byte = 0x64

    /// e
    static let e: Byte = 0x65

    /// f
    static let f: Byte = 0x66

    /// g
    static let g: Byte = 0x67

    /// h
    static let h: Byte = 0x68

    /// i
    static let i: Byte = 0x69

    /// j
    static let j: Byte = 0x6A

    /// k
    static let k: Byte = 0x6B

    /// l
    static let l: Byte = 0x6C

    /// m
    static let m: Byte = 0x6D

    /// n
    static let n: Byte = 0x6E

    /// o
    static let o: Byte = 0x6F

    /// p
    static let p: Byte = 0x70

    /// q
    static let q: Byte = 0x71

    /// r
    static let r: Byte = 0x72

    /// s
    static let s: Byte = 0x73

    /// t
    static let t: Byte = 0x74

    /// u
    static let u: Byte = 0x75

    /// v
    static let v: Byte = 0x76

    /// w
    static let w: Byte = 0x77

    /// x
    static let x: Byte = 0x78

    /// y
    static let y: Byte = 0x79

    /// z
    static let z: Byte = 0x7A
}


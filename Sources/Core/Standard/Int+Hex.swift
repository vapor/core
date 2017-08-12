#if swift(>=4)
    extension FixedWidthInteger {
        /// Convert a Signed integer into a hex string representation
        /// 255 -> FF
        /// NOTE: Will always return UPPERCASED VALUES
        public var hex: String {
            return String(self, radix: 16).uppercased()
        }
    }

#else
    extension SignedInteger {
        public var hex: String {
            return String(self, radix: 16).uppercased()
        }
    }
    extension UnsignedInteger {
        public var hex: String {
            return String(self, radix: 16).uppercased()
        }
    }
#endif

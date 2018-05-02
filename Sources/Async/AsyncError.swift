/// Logs verbose debug info if `VERBOSE` compiler flag is enabled.
internal func VERBOSE(_ string: @autoclosure () -> (String)) {
    #if VERBOSE
    print("[VERBOSE] [Async] \(string())")
    #endif
}


/// Only includes the supplied closure in non-release builds.
internal func debugOnly(_ body: () -> Void) {
    assert({ body(); return true }())
}

/// Logs a runtime warning.
internal func WARNING(_ string: @autoclosure () -> String) {
    print("[WARNING] [Async] \(string())")
}


/// Logs an unhandleable runtime error.
internal func ERROR(_ string: @autoclosure () -> String) {
    print("[ERROR] [Async] \(string())")
}

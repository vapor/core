/// Logs verbose debug info if `VERBOSE` compiler flag is enabled.
internal func VERBOSE(_ string: @autoclosure () -> (String)) {
    #if VERBOSE
    print("[VERBOSE] [Async] \(string())")
    #endif
}

/// Logs an unhandleable runtime error.
internal func ERROR(_ string: @autoclosure () -> String) {
    print("[ERROR] [Async] \(string())")
}

func VERBOSE(_ string: @autoclosure () -> (String)) {
    #if VERBOSE
    print("[VERBOSE] [Async] \(string())")
    #endif
}

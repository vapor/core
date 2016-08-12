import libc
import Core

func testSemaphore() throws {
    var collection = [String]()
    let semaphore = Semaphore()

    collection.append("a")
    try Core.background {
        collection.append("b")
        sleep(1)
        collection.append("c")
        semaphore.signal()
    }
    collection.append("e")
    _ = semaphore.wait(timeout: (60 * 60 * 5000))
    collection.append("f")

    print("**** I RAN ****")
    assert(collection == ["a", "e", "b", "c", "f"])
}

//func testSemaphoreTimeout() throws {
//    try (1...3).forEach { timeoutTest in
//        let semaphore = Semaphore()
//        print("¶¶1")
//        try background {
//            print("¶¶2")
//            let sleeptime = timeoutTest * 2
//            print("¶¶3 \(sleeptime)")
//            sleep(UInt32(sleeptime))
//            print("¶¶4")
//            semaphore.signal()
//            print("¶¶5")
//        }
//        print("¶¶6")
//        let result = semaphore.wait(timeout: Double(timeoutTest))
//        print("¶¶7 \(result)")
//        assert(result == .timedOut)
//    }
//}

try testSemaphore()
//try testSemaphoreTimeout()

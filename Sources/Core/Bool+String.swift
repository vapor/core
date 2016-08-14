// extension Bool {
//     /**
//         This function seeks to replicate the expected
//         behavior of `var boolValue: Bool` on `NSString`.
//         Any variant of `yes`, `y`, `true`, `t`, or any
//         numerical value greater than 0 will be considered `true`
//     */
//     public init?(_ string: String) {
//         switch string.lowercased() {
//         case "y", "1", "yes", "t", "true":
//             self = true
//         case "n", "0", "no", "f", "false":
//             self = false
//         default:
//             return nil
//         }
//     }
// }

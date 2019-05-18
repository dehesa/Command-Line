import Foundation

extension CommandLine {
    /// The argument right after the indicated flag.
    /// - parameter flag: String to be matched exactly within the arguments array.
    /// - returns: A string if the flag was found, in which case it will be the parameter right after the flag.
    internal static func parameter(for flag: String) -> String? {
        let arguments: [String] = CommandLine.arguments
        guard let flagIndex = arguments.firstIndex(of: flag) else { return nil }
        
        let parameterIndex = arguments.index(after: flagIndex)
        guard parameterIndex < arguments.endIndex else { return "" }
        
        return arguments[parameterIndex]
    }
}

extension CommandLine {
    /// Select between the standard output and the standard error.
    internal enum Output {
        case stdout, stderr
    }
    
    /// Writes on the output the specific message.
    internal static func write(to output: Output, _ message: String) {
        let data = Data(message.utf8)
        switch output {
        case .stdout: FileHandle.standardOutput.write(data)
        case .stderr: FileHandle.standardError.write(data)
        }
    }
}

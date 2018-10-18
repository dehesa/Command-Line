import Foundation

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

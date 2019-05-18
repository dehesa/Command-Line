import Foundation

/// Namespace for the sanitizer functions.
enum Sanitizer {
    /// Retrieve the root directory from the given arguments. If no arguments define the root directory, the current working directory is inferred.
    /// - parameter arguments: The Command-Line arguments. The first argument shall be the name of the program.
    /// - returns: A directory URL.
    static func rootDirectory(from arguments: [String]) -> URL {
        guard arguments.count > 1 else {
            let pwd = FileManager.default.currentDirectoryPath
            return URL(fileURLWithPath: pwd, isDirectory: true)
        }
        
        guard arguments.count == 2 else {
            CommandLine.write(to: .stderr, "This command-line application expects no arguments or a single folder path.\n")
            exit(EXIT_FAILURE)
        }
        
        guard let path = arguments.last,
              let result = Sanitizer.path(path) else {
            CommandLine.write(to: .stderr, "The provided path is invalid.\n")
            exit(EXIT_FAILURE)
        }
        
        guard let isReachable = try? result.checkResourceIsReachable(), isReachable else {
            CommandLine.write(to: .stderr, "The provided path \"\(result.absoluteString)\" is invalid.\n")
            exit(EXIT_FAILURE)
        }
        
        // TODO: Validate that the url points to a folder.
        return result
    }
}

private extension Sanitizer {
    /// Check the input path and expand it in case it is relative.
    static func path(_ path: String) -> URL? {
        // Check if the path is absolute.
        guard !path.hasPrefix("/") else {
            return URL(fileURLWithPath: path)
        }
        
        // Check if the path has a "tilde".
        guard !path.hasPrefix("~") else {
            return URL(fileURLWithPath: NSString(string: path).standardizingPath)
        }
        
        // At this point, the path can only be relative to the current directory.
        let pwd = FileManager.default.currentDirectoryPath
        return URL(fileURLWithPath: pwd).appendingPathComponent(path)
    }
}

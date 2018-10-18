import Foundation

/// Namespace for the detection functions.
enum Detector {
    /// Checks whether the given url is a git folder or not.
    /// - parameter url: The url of the targeted folder.
    /// - parameter hiddenSubfolderName: The subfolder name identifying this project as a git project.
    static func isGitProject(_ url: URL, hiddenSubfolderName: String = ".git") -> Bool {
        let resourceKeys: [URLResourceKey] = [.nameKey, .isHiddenKey, .isDirectoryKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants]
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: options, errorHandler: {
            CommandLine.write(to: .stderr, "Encounter error on \"\($0)\"\n\t\($1)\n")
            return true
        }) else {
            CommandLine.write(to: .stderr, "FileManager enumerator couldn't be created.\n")
            exit(EXIT_FAILURE)
        }
        
        let keySet = Set(resourceKeys)
        for case let targetURL as URL in enumerator {
            do {
                let resourceValues = try targetURL.resourceValues(forKeys: keySet)
                
                guard let isDirectory = resourceValues.isDirectory else {
                    throw makeError(code: -1, message: "FileManager couldn't figure out whether the resource was a file or a directory.")
                }
                
                guard isDirectory else { continue }
                
                guard let isHidden = resourceValues.isHidden else {
                    throw makeError(code: -1, message: "FileManager couldn't figure out whether the resource was hidden or public.")
                }
                
                guard isHidden else { continue }
                
                guard let name = resourceValues.name else {
                    throw makeError(code: -1, message: "FileManager couldn't figure out the name of the folder at path: \(targetURL)")
                }
                
                if name == hiddenSubfolderName { return true }
            } catch let error {
                CommandLine.write(to: .stderr, "Encounter error on \"\(targetURL)\"\n\t\(error)\n")
                continue
            }
        }
        
        return false
    }
    
    /// Returns all the git projects under the given url.
    /// - parameter url: The parent URL from which the iteration will start.
    /// - returns: An array of absolute address of git projects.
    static func gitProjects(from url: URL) -> [URL] {
        // If the given address is a git project, no more processing is needed.
        guard !isGitProject(url) else { return [url] }
        
        let resourceKeys: [URLResourceKey] = [.isHiddenKey, .isDirectoryKey]
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: [.skipsPackageDescendants], errorHandler: {
            CommandLine.write(to: .stderr, "Encounter error on \"\($0)\"\n\t\($1)\n")
            return true
        }) else {
            CommandLine.write(to: .stderr, "FileManager enumerator couldn't be created.\n")
            exit(EXIT_FAILURE)
        }
        
        let keySet = Set(resourceKeys)
        var result: [URL] = []
        /// Enumerate through all files and folders under the given URL.
        for case let targetURL as URL in enumerator {
            do {
                let resourceValues = try targetURL.resourceValues(forKeys: keySet)
                
                // If the resource is a file, then ignore it.
                guard let isDirectory = resourceValues.isDirectory else {
                    throw makeError(code: -1, message: "FileManager couldn't figure out whether the resource was a file or a directory.")
                }
                
                guard isDirectory else { continue }
                
                // If the resource is a hidden folder, then ignore it.
                guard let isHidden = resourceValues.isHidden else {
                    throw makeError(code: -1, message: "FileManager couldn't figure out whether the resource was hidden or public.")
                }
                
                guard !isHidden else {
                    enumerator.skipDescendants()
                    continue
                }
                
                // If the resource is a git project, stored the URL in the result and don't introspect more.
                if isGitProject(targetURL) {
                    enumerator.skipDescendants()
                    result.append(targetURL)
                }
            } catch let error {
                CommandLine.write(to: .stderr, "Encounter error on \"\(targetURL)\"\n\t\(error)\n")
                continue
            }
        }
        
        return result
    }
}

private extension Detector {
    /// Makes an error thrown by the detector.
    static func makeError(code: Int, message: String, function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        let domain = "me.dehesa.cmd.git"
        let funcKey = domain + ".function"
        let fileKey = domain + ".file"
        let lineKey = domain + ".line"
        
        return NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message,
            funcKey: function, fileKey: file, lineKey: line
        ])
    }
}

import Foundation

/// Namespace for the sanitizer functions.
enum Sanitizer {
    /// Parses the Command-Line arguments for the targeted forlder path.
    /// - parameters arguments: The Command-Line arguments. The first one shall be the name of the program.
    static func parse(arguments: [String]) -> Arguments {
        var introspected: (path: String?, key: String?) = (nil, nil)
        
        var index = 1
        while index < arguments.count {
            switch arguments[index] {
            case "-k":
                guard case .none = introspected.key else {
                    CommandLine.write(to: .stderr, "Only one PLIST key is expected.\n")
                    exit(EXIT_FAILURE)
                }
                
                index += 1
                guard index < arguments.count else {
                    CommandLine.write(to: .stderr, "No PLIST key was provided.\n")
                    exit(EXIT_FAILURE)
                }
                
                introspected.key = arguments[index]
            default:
                guard case .none = introspected.path else {
                    CommandLine.write(to: .stderr, "File paths cannot be written more than once.\n")
                    exit(EXIT_FAILURE)
                }
                introspected.path = arguments[index]
            }
            
            index += 1
        }
        
        guard case .some(let path) = introspected.path,
              case .some(let key) = introspected.key, !key.isEmpty else {
            CommandLine.write(to: .stderr, "A file/folder path and a PLIST key must be provided for the program to work.\n")
            exit(EXIT_FAILURE)
        }
        
        let url = URL(fileURLWithPath: path)
        guard let isReachable = try? url.checkResourceIsReachable(), isReachable else {
            CommandLine.write(to: .stderr, "Invalid path: \"path\"\n")
            exit(EXIT_FAILURE)
        }
        
        // TODO: Validate that the url points to a folder
        return Arguments(url: url, key: key)
    }
}

extension Sanitizer {
    struct Arguments {
        let url: URL
        let key: String
    }
}

extension Sanitizer {
    static func representation(_ value: Any, indentationLevel level: Int) -> String {
        let tab = String(repeating: "\t", count: level)
        
        if let boolean = value as? Bool {
            return (boolean) ? "true" : "false"
        } else if let number = value as? NSNumber {
            return number.stringValue
        } else if let string = value as? String {
            return "\"" + string + "\""
        } else if let array = value as? [Any] {
            guard !array.isEmpty else { return "[]" }
            
            return "[" + array.map { representation($0, indentationLevel: level+1) }.joined(separator: ", ") + "]"
        } else if let dictionary = value as? [String:Any] {
            guard !dictionary.isEmpty else { return "{}" }
            let indentation = tab + "\t"
            
            var result = "{\n"
            for (key, value) in dictionary {
                result += indentation + key + ": " + representation(value, indentationLevel: level + 1) + "\n"
            }
            return result + tab + "}"
        } else {
            print(type(of: value))
            return "\(value)"
        }
    }
    
    static func curateURL(_ url: URL, prefix: TemplatesPath) -> String {
        let prefix = "file://" + prefix.rawValue
        let suffix = ".xctemplate/TemplateInfo.plist"
        return url.absoluteString
            .dropFirst(prefix.count)
            .dropLast(suffix.count)
            .replacingOccurrences(of: "%20", with: " ")
    }
}

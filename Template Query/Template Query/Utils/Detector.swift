import Foundation

/// Namespace for the detection functions.
enum Detector {
    /// Checks whether the url given as argument point to an Xcode template PLIS file.
    /// - paramter url: The URL pointing to a file or directory.
    /// - returns: Boolean value indicating whether the url is a file and an Xcode template PLIST file.
    static func isXcodeTemplate(url: URL) -> Bool {
        guard url.isFileURL,
              let fileName = url.pathComponents.last,
              fileName.uppercased() == "TEMPLATEINFO.PLIST" else { return false }
        return true
    }
    
    /// Returns all the template files URLs under the given url.
    /// - parameter url: Directory or file URL.
    static func xcodeTemplateURLs(under url: URL) throws -> [URL] {
        guard url.hasDirectoryPath else {
            guard Detector.isXcodeTemplate(url: url) else { throw Error.invalidTemplateFile(url) }
            return [url]
        }
        
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: { (url, error) -> Bool in
            CommandLine.write(to: .stderr, "Encounter error at \"\(url)\"\n\t\(error)\n")
            return true
        }) else {
            throw Error.treeSearchFailedToInitiate(at: url)
        }
        
        var result: [URL] = []
        for case let targetURL as URL in enumerator where isXcodeTemplate(url: targetURL) {
            result.append(targetURL)
        }
        
        return result
    }
    
    /// Returns the PLIST file as a dictionary.
    /// - parameter url: The URL pointing to a PLIST file.
    /// - returns: Dictionary with the whole content of the template.
    static func plist(url: URL) throws -> [String:Any] {
        let data = try Data(contentsOf: url)
        let result = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return result as! [String:Any]
    }
    
    /// Returns the PLIST file as an Xcode Template instance.
    /// - parameter url: The URL pointing to a PLIST file.
    /// - returns: Instance representing an Xcode template.
    static func xcodeTemplate(url: URL) throws -> Template {
        let data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode(Template.self, from: data)
    }
    
//    /// Unwraps the `Ancestor` properties.
//    static func unwrapXcodeTemplate(top: [String:Any], pool: [[String:Any]]) throws -> [String:Any] {
//        guard let ancestors = top[Template.Key.ancestors.rawValue] as? [String], !ancestors.isEmpty else { return top }
//
//        var result = top
//        for ancestor in ancestors {
////            merge(ancestor: ancestor, in: &result, pool: pool)
//        }
//        return result
//    }
}
//
//extension Detector {
//    private static func merge(ancestor: [String:Any], in result: inout [String:Any], pool: [[String:Any]]) throws {
//
//    }
//
//    private static func findAncestor(id ancestorId: String, pool: [[String:Any]]) -> [String:Any]? {
//
//    }
//}

extension Detector {
    /// Errors thrown exclusively by the `Detector`.
    enum Error: Swift.Error {
        case invalidTemplateFile(URL)
        case treeSearchFailedToInitiate(at: URL)
    }
}

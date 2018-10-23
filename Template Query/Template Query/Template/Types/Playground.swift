//import Foundation
//
//extension Template {
//    /// Template for a future Xcode playground.
//    public struct Playground {
//        /// Represent the type of template.
//        private let kind: Kind = .playground
//        /// Template name appearing on the template browser
//        public var name: String
//        /// A short description of this template.
//        public var summary: String
//        /// A lengthy text description of what the template does.
//        public var description: String
//        /// Platforms supported by this playground.
//        public let platforms: [Platform] = [.macOS, .iOS, .tvOS]
//        /// Overrides the default alphabetical sort order in the template browser.
//        public var sortOrder: Int = 20
//        /// Types allowed to be stored in the template folder.
//        private let allowedTypes: [FileType] = [.playground]
//        /// The name given to the playground by default that will appear on the completion textfield of the "Save As" panel.
//        public var playgroundFileName: String = "MyPlayground"
//        /// The location of the main `.playground` file.
//        public var playgroundFileContent: String = Variable.fileBaseName + ".playground"
//    }
//}
//
//extension Template.Playground {
//    init(name: String, summary: String, description: String) {
//        self.name = name
//        self.summary = summary
//        self.description = description
//    }
//
//    public func generateFiles(url: URL) throws {
//        let folderName = self.name + "." + Template.packageExtension
//        let folderURL = url.appendingPathComponent(folderName, isDirectory: true)
//        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
//
//        let templateFileURL = folderURL.appendingPathComponent(Template.plist)
//        let data = try PropertyListEncoder().encode(self)
//        try data.write(to: templateFileURL)
//    }
//}
//
//extension Template.Playground: Codable {
//    private enum CodingKeys: String, CodingKey {
//        case kind = "Kind"
//        case name = "Name"
//        case summary = "Summary"
//        case description = "Description"
//        case platforms = "Platforms"
//        case sortOrder = "SortOrder"
//        case allowedTypes = "AllowedTypes"
//        case playgroundFileName = "DefaultCompletionName"
//        case playgroundFileContent = "MainTemplateFile"
//    }
//}

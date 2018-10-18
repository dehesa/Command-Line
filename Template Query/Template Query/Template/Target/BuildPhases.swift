import Foundation

extension Template.Target.Build {
    /// Build phases defined in the receiving target.
    public struct Plan: MutableCollection, RandomAccessCollection, Codable, CustomStringConvertible {
        /// Build phases contained in this build plan.
        ///
        /// The order of the build phases is important.
        private var phases: [BuildPhase] = []
        
        /// Initializer for no phases.
        public init() {}
        
        /// Tries to store all given phases.
        ///
        /// This initializer will fail if there are copies of phases that must be unique.
        public init?(phases: [BuildPhase]) {
            for phase in phases {
                guard self.append(phase) else { return nil }
            }
        }
        
        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            while !container.isAtEnd {
                let subdecoder = try container.superDecoder()
                let nestedContainer = try subdecoder.container(keyedBy: CodingKeys.self)
                
                switch try nestedContainer.decode(Phase.self, forKey: .class) {
                case .includeHeaders:
                    self.phases.append(try Headers(from: subdecoder))
                case .compileSources:
                    self.phases.append(try Sources(from: subdecoder))
                case .copyResourcesToBundle:
                    self.phases.append(try Resources(from: subdecoder))
                case .linkBinaryWithLibraries:
                    self.phases.append(try Frameworks(from: subdecoder))
                case .copyFiles:
                    self.phases.append(try Files(from: subdecoder))
                case .runScripts:
                    self.phases.append(try Script(from: subdecoder))
                }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            for phase in self.phases {
                try phase.encode(to: container.superEncoder())
            }
        }
        
        public var description: String {
            let result: [String] = self.phases.map { $0.description }
            return "[" + result.joined(separator: ", ") + "]"
        }
        
        public var startIndex: Int {
            return self.phases.startIndex
        }
        
        public var endIndex: Int {
            return self.phases.endIndex
        }
        
        public subscript(_ index: Int) -> BuildPhase {
            get {
                return self.phases[index]
            }
            
            set {
                let previousValue = self.phases.remove(at: index)
                let value = self.canStore(phase: newValue) ? newValue : previousValue
                self.phases.insert(value, at: index)
            }
        }
        
        /// Appends the given build phase to the end of the already stored build phases.
        ///
        ///
        /// - returns: Boolean value indicating whether the build phase was stored successfuly.
        @discardableResult
        public mutating func append(_ newElement: Element) -> Bool {
            guard self.canStore(phase: newElement) else { return false }
            self.phases.append(newElement)
            return true
        }
        
        public mutating func append(contentsOf newElements: [BuildPhase]) {
            for element in newElements { self.append(element) }
        }
        
        /// Returns a boolean indicating whether the given build phase can be stored.
        ///
        /// Some build phases can only be defined once.
        private func canStore(phase: BuildPhase) -> Bool {
            switch phase.type {
            case .copyFiles, .runScripts:
                return true
            case .includeHeaders, .compileSources, .copyResourcesToBundle, .linkBinaryWithLibraries :
                return !self.phases.contains { $0.type == phase.type }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case `class` = "Class"
        }
    }
}

extension Template.Target.Build {
    /// The type of build phase.
    public enum Phase: String, Codable {
        case includeHeaders = "Headers"
        case compileSources = "Sources"
        case copyResourcesToBundle = "Resources"
        case linkBinaryWithLibraries = "Frameworks"
        case copyFiles = "CopyFiles"
        case runScripts = "ShellScript"
    }
}

public protocol BuildPhase: Codable, CustomStringConvertible {
    /// The type of build phase.
    var type: Template.Target.Build.Phase { get }
}

extension Template.Target.Build.Plan {
    /// Build phase to include headers (whether public, project, or private).
    public struct Headers: BuildPhase {
        public let type: Template.Target.Build.Phase = .includeHeaders
        public var description: String { return "Include headers" }
        /// Designated initializer.
        public init() {}
        
        private enum CodingKeys: String, CodingKey {
            case type = "Class"
        }
    }
    
    /// Build phase to compile sources.
    public struct Sources: BuildPhase {
        public let type: Template.Target.Build.Phase = .compileSources
        public var description: String { return "Compile sources" }
        /// Designated initializer.
        public init() {}
        
        private enum CodingKeys: String, CodingKey {
            case type = "Class"
        }
    }
    
    /// Build phase to copy resources in the bundle target.
    public struct Resources: BuildPhase {
        public let type: Template.Target.Build.Phase = .copyResourcesToBundle
        public var description: String { return "Copy resources to bundle" }
        /// Designated initializer.
        public init() {}
        
        private enum CodingKeys: String, CodingKey {
            case type = "Class"
        }
    }
    
    /// Build phase to link libraries in the built project.
    public struct Frameworks: BuildPhase {
        public let type: Template.Target.Build.Phase = .linkBinaryWithLibraries
        public var description: String { return "Link libraries" }
        /// Designated initializer.
        public init() {}
        
        private enum CodingKeys: String, CodingKey {
            case type = "Class"
        }
    }
    
    /// Build phase to run script.
    public struct Script: BuildPhase {
        public let type: Template.Target.Build.Phase = .runScripts
        /// The program in charge of running the script.
        public var programPath: String
        /// The content of the shell script.
        public var script: String
        
        /// Initializes a build script with the program running it and the actual script.
        public init(programURL: String = "/bin/sh", script: String) {
            self.programPath = programURL
            self.script = script
        }
        
        public var description: String {
            return "Run Scripts with \(self.programPath)"
        }
        
        private enum CodingKeys: String, CodingKey {
            case type = "Class"
            case programPath = "ShellPath"
            case script = "ShellScript"
        }
    }
    
    /// Build phase to copy files from one place in the file system to another.
    public struct Files: BuildPhase {
        public let type: Template.Target.Build.Phase = .copyFiles
        /// The "logical" destination location.
        public var destination: Destination
        /// The destination relative path.
        public var path: String
        /// Whether the copy phase shall only be executed when installing the program.
        ///
        /// The programmatic name is: `RunOnlyForDeploymentPostprocessing`.
        public var copyOnlyWhenInstalling: Bool = true
        
        /// Initializes a "copy files" build phase with a logical destination and the path.
        public init(destination: Destination, path: String) {
            self.destination = destination
            self.path = path
        }

        public var description: String {
            return "Copy files to \(self.path) (\(self.destination.description))"
        }
        
        private enum CodingKeys: String, CodingKey {
            case type = "Class"
            case destination = "DstSubfolderSpec"
            case path = "DstPath"
            case copyOnlyWhenInstalling = "RunOnlyForDeploymentPostprocessing"
        }
    }
}

extension Template.Target.Build.Plan.Files {
    /// The type of destination for the copy files build phase.
    public enum Destination: Int, Codable, CustomStringConvertible {
        case absolutePath = 0
        case productsDirectory
        case wrapper
        case executables
        case resources
        case javaResources
        case frameworks
        case sharedFrameworks
        case sharedSupport
        case plugIns
        case xpcServices
        
        public var description: String {
            switch self {
            case .absolutePath: return "Absolute Path"
            case .productsDirectory: return "Products Directory"
            case .wrapper: return "Wrapper"
            case .executables: return "Executables"
            case .resources: return "Resources"
            case .javaResources: return "Java Resources"
            case .frameworks: return "Frameworks"
            case .sharedFrameworks: return "Shared Frameworks"
            case .sharedSupport: return "Shared Support"
            case .plugIns: return "Plug-Ins"
            case .xpcServices: return "XPC Services"
            }
        }
    }
}

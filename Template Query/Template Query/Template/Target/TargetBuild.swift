import Foundation

extension Template.Target {
    /// Build properties for the receiving target.
    public struct Build: Codable {
        /// Build settings.
        public var settings: Settings
        /// Build dependencies to create a target.
        public var dependencies: Dependencies
        /// The build phases for the given target.
        public var phases: Plan
        /// Tool used to build the receiving target.
        public var tool: Tool? = nil
        
        public init(frameworkDependencies frameworks: [String] = []) {
            self.settings = Settings()
            self.dependencies = Dependencies(frameworks: frameworks)
            self.phases = Plan()
        }
        
        public init(from decoder: Decoder) throws {
            self.settings = try Settings(from: decoder)
            self.dependencies = try Dependencies(from: decoder)
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.phases = try container.decodeIfPresent(Plan.self, forKey: .phases) ?? Plan()
            
            if let toolPath = try container.decodeIfPresent(String.self, forKey: .toolPath) {
                let args = try container.decodeIfPresent(String.self, forKey: .toolArgs)
                self.tool = Tool(path: toolPath, args: args)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            guard !self.isEmpty else { return }
            
            try self.settings.encode(to: encoder)
            try self.dependencies.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let tool = self.tool {
                try container.encode(tool.path, forKey: .toolPath)
                try container.encodeIfPresent(tool.args, forKey: .toolArgs)
            }
            
            if !self.phases.isEmpty {
                try container.encode(self.phases, forKey: .phases)
            }
        }
        
        public var isEmpty: Bool {
            return self.settings.isEmpty &&
                   self.dependencies.isEmpty &&
                   self.phases.isEmpty &&
                   self.tool == nil
        }
        
        private enum CodingKeys: String, CodingKey {
            case phases = "BuildPhases"
            case toolPath = "BuildToolPath"
            case toolArgs = "BuildToolArgsString"
        }
    }
}

extension Template.Target.Build {
    /// Definition of a build tool.
    public struct Tool {
        /// The path for the build tool.
        public var path: String
        /// The arguments to pass to the build tool.
        public var args: String?
        
        public init(path: String, args: String?) {
            self.path = path
            self.args = args
        }
    }
}

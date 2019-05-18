import Foundation

extension Template.Target.Build {
    /// Build dependencies.
    public struct Dependencies: Codable {
        /// Dependencies of this project in the form of target identifiers.
        public var targets: [String]
        /// Frameworks that must be there for the target to build.
        ///
        /// The `String`s represent the Framework's name (e.g. `Cocoa`, `NotificationCenter`, `Quartz`, `Photos`)
        public var frameworks: [String]
        
        public init(targets: [String]? = nil, frameworks: [String]? = nil) {
            self.targets = targets ?? []
            self.frameworks = frameworks ?? []
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.targets = []
            if container.contains(.injections) {
                var array = try container.nestedUnkeyedContainer(forKey: .injections)
                
                while !array.isAtEnd {
                    let dictionary = try array.nestedContainer(keyedBy: CodingKeys.InjectionKeys.self)
                    let targetId = try dictionary.decode(String.self, forKey: .targetId)
                    self.targets.append(targetId)
                }
            }
            
            self.frameworks = try container.decodeIfPresent([String].self, forKey: .frameworks) ?? []
        }
        
        public func encode(to encoder: Encoder) throws {
            guard !self.isEmpty else { return }
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            if !self.targets.isEmpty {
                var injections = container.nestedUnkeyedContainer(forKey: .injections)
                for targetId in targets {
                    var target = injections.nestedContainer(keyedBy: CodingKeys.InjectionKeys.self)
                    try target.encode(targetId, forKey: .targetId)
                }
            }
            
            if !self.frameworks.isEmpty {
                try container.encode(self.frameworks, forKey: .frameworks)
            }
        }
        
        /// Boolean indicating wether there are no dependencies.
        public var isEmpty: Bool {
            return self.targets.isEmpty && self.frameworks.isEmpty
        }
        
        private enum CodingKeys: String, CodingKey {
            case injections = "ProductBuildPhaseInjections"
            case frameworks = "Frameworks"
            
            enum InjectionKeys: String, CodingKey {
                case targetId = "TargetIdentifier"
            }
        }
    }
}

import Foundation

extension Template.Target.Build {
    /// Build settings and configurations.
    public struct Settings: Codable {
        /// The settings shared among all configurations.
        private var shared: [String:Any] = [:]
        /// The settings for each configuration.
        private var configurations: [Configuration:[String:Any]] = [:]
        
        /// Initializes the build settings with default values.
        public init() {}
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let settings = try container.decodeIfPresent([String:CoreCodingValue].self, forKey: .sharedSettings) {
                self.shared = settings.mapValues { $0.content }
            }
            
            guard let configs = try container.decodeIfPresent([String:[String:CoreCodingValue]].self, forKey: .configurations) else { return }
            for (key, value) in configs {
                guard let configuration = Configuration(rawValue: key) else {
                    throw DecodingError.dataCorruptedError(forKey: .configurations, in: container, debugDescription: "The configuration \"\(key)\" is invalid")
                }
                self.configurations[configuration] = value.mapValues { $0.content }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            let settingEncoder: (inout KeyedEncodingContainer<CommonCodingKey>, [String:Any]) throws -> () = {
                for (k, v) in $1 {
                    guard let key = CommonCodingKey(stringValue: k) else {
                        let context = EncodingError.Context(codingPath: $0.codingPath, debugDescription: "The build setting couldn't be encoded.")
                        throw EncodingError.invalidValue(k, context)
                    }
                    
                    guard let value = CoreCodingValue(v) else {
                        let context = EncodingError.Context(codingPath: $0.codingPath, debugDescription: "The build setting \"\(k)\" value couldn't be encoded.")
                        throw EncodingError.invalidValue(v, context)
                    }
                    
                    try $0.encode(value, forKey: key)
                }
            }
            
            if !self.shared.isEmpty {
                var subcontainer = container.nestedContainer(keyedBy: CommonCodingKey.self, forKey: .sharedSettings)
                try settingEncoder(&subcontainer, self.shared)
            }
            
            guard !self.configurations.isEmpty else { return }
            var configContainer = container.nestedContainer(keyedBy: CommonCodingKey.self, forKey: .configurations)
            
            for (config, settings) in self.configurations {
                guard let key = CommonCodingKey(stringValue: config.rawValue) else {
                    let ctx = EncodingError.Context(codingPath: configContainer.codingPath, debugDescription: "The build configuration is invalid.")
                    throw EncodingError.invalidValue(config, ctx)
                }
                
                var subcontainer = configContainer.nestedContainer(keyedBy: CommonCodingKey.self, forKey: key)
                try settingEncoder(&subcontainer, settings)
            }
        }
        
        /// Boolean indicating whether there is any build configuration or build setting defined.
        public var isEmpty: Bool {
            return self.shared.isEmpty && self.configurations.isEmpty
        }
        
        /// Returns all the build settings for the given build configuration.
        /// - parameter configuration: If `nil`, it represents the *shared* build settings.
        /// - returns: A dictionary with all build settings.
        public subscript(configuration: Configuration?) -> [String:Any] {
            guard let configuration = configuration else {
                return self.shared
            }
            
            return self.configurations[configuration] ?? [:]
        }
        
        /// Returns a build setting value for a specific build configuration and build setting key.
        /// - parameter configuration: If `nil`, it represents the *shared* build settings.
        /// - returns: A `Bool`, `Int`, `Double`, or `String` value.
        public subscript(configuration: Configuration?, key: String) -> Any? {
            get {
                guard let configuration = configuration else {
                    return self.shared[key]
                }
                
                return self.configurations[configuration]?[key]
            }
            
            set {
                guard let configuration = configuration else {
                    self.shared[key] = newValue; return
                }
                
                var dictionary = self.configurations[configuration] ?? [:]
                dictionary[key] = newValue
                
                if dictionary.isEmpty {
                    self.configurations.removeValue(forKey: configuration)
                } else {
                    self.configurations[configuration] = dictionary
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case sharedSettings = "SharedSettings"
            case configurations = "Configurations"
        }
    }
}

extension Template.Target.Build.Settings {
    /// Configuration names for the build settings.
    public enum Configuration: Codable, RawRepresentable, Hashable {
        case debug
        case release
        case custom(String)
        
        public init?(rawValue: String) {
            switch rawValue {
            case Configuration.debug.rawValue:   self = .debug
            case Configuration.release.rawValue: self = .release
            default:
                guard !rawValue.isEmpty else { return nil }
                self = .custom(rawValue)
            }
        }
        
        public var rawValue: String {
            switch self {
            case .debug: return "Debug"
            case .release: return "Release"
            case .custom(let value): return value
            }
        }
    }
}

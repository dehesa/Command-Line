import Foundation


public protocol TemplateDefinition: Codable {
    ///
    var type: Template.Definitions.Kind { get }
}


extension Template {
    /// Definitions describes in an Xcode template.
    public struct Definitions: Sequence, Codable {
        public typealias Index = Dictionary<String,TemplateDefinition>.Index
        ///
        private var specifications: [String:TemplateDefinition]
        
        ///
        public init(_ definitions: [String:TemplateDefinition] = [:]) {
            self.specifications = definitions
        }
        
        public init(from decoder: Decoder) throws {
            self.specifications = [:]
            
            let container = try decoder.container(keyedBy: CommonCodingKey.self)
            for key in container.allKeys {
                if let raw = try? container.decode(Raw.self, forKey: key) {
                    self.specifications[key.stringValue] = raw
                } else if let container = try? container.decode(Container.self, forKey: key) {
                    self.specifications[key.stringValue] = container
                } else if let generator = try? container.decode(AssetsCatalog.self, forKey: key) {
                    self.specifications[key.stringValue] = generator
                } else if let file = try? container.decode(File.self, forKey: key) {
                    self.specifications[key.stringValue] = file
                } else {
                    let custom = try? container.decode(Custom.self, forKey: key)
                    self.specifications[key.stringValue] = custom
                }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CommonCodingKey.self)
            for (key, value) in self.specifications {
                guard let codingKey = CommonCodingKey(stringValue: key) else {
                    let ctx = EncodingError.Context(codingPath: container.codingPath, debugDescription: "The key for the definition is invalid.")
                    throw EncodingError.invalidValue(key, ctx)
                }
                let subencoder = container.superEncoder(forKey: codingKey)
                try value.encode(to: subencoder)
            }
        }
        
        public var isEmpty: Bool {
            return self.specifications.isEmpty
        }

        public subscript(_ key: String) -> TemplateDefinition? {
            get {
                return self.specifications[key]
            }

            set {
                self.specifications[key] = newValue
            }
        }
        
        public func makeIterator() -> Dictionary<String,TemplateDefinition>.Iterator {
            return self.specifications.makeIterator()
        }
        
        fileprivate enum CodingKeys: String, CodingKey {
            // Int values
            case indent = "Indent"
            case order = "SortOrder"
            case substituionMacros = "SubstituteMacros"
            // String values
            case beginning = "Beginning"
            case end = "End"
            case path = "Path"
            // Array<Any> values
            case assetGeneration = "AssetGeneration"
            case buildAttributes = "BuildAttributes"
            case targets = "TargetIdentifiers"
        }
    }
}


extension Template.Definitions {
    /// The type of definition being described.
    public enum Kind {
        /// The definition is just a long `String`.
        case raw
        /// The definition describes a container with a beginning and an end.
        case container
        /// The definition describes an asset container (`.xcassets`).
        case assetGeneration
        /// File/Folder definition.
        case file
        /// Non-Standard definition
        case custom
    }
    
    /// A *raw* definition where only a long `String` is given.
    public struct Raw: TemplateDefinition {
        public var type: Template.Definitions.Kind { return .raw }
        /// The long `String` definition.
        public var value: String
        /// Initializer providing the description as argument.
        public init(_ value: String) {
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(String.self)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
    }
    
    ///
    public struct Container: TemplateDefinition {
        public var type: Template.Definitions.Kind { return .container }
        ///
        public var beginning: String
        ///
        public var end: String
        ///
        public var indent: Int?
        ///
        public var order: Int?
        ///
        public var containsSubstitutionMacros: Bool
        
        public init(beginning: String, end: String, indent: Int? = nil) {
            self.beginning = beginning
            self.end = end
            self.indent = indent
            self.containsSubstitutionMacros = false
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.beginning = try container.decode(String.self, forKey: .beginning)
            self.end = try container.decode(String.self, forKey: .end)
            self.indent = try container.decodeIfPresent(Int.self, forKey: .indent)
            self.order = try container.decodeIfPresent(Int.self, forKey: .order)
            self.containsSubstitutionMacros = try container.decodeIfPresent(Bool.self, forKey: .substituionMacros) ?? false
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.beginning, forKey: .beginning)
            try container.encode(self.end, forKey: .end)
            try container.encodeIfPresent(self.indent, forKey: .indent)
            try container.encodeIfPresent(self.order, forKey: .order)
            if self.containsSubstitutionMacros { try container.encode(true, forKey: .substituionMacros) }
        }
    }
    
    public struct AssetsCatalog: TemplateDefinition {
        public var type: Template.Definitions.Kind { return .assetGeneration }
        /// The path for the asset container.
        public var path: String
        /// The assets being generated.
        public var assets: [Asset]
        ///
        public var targetIds: [String]
        /// The visual position/order.
        public var order: Int?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.assets = try container.decode([Asset].self, forKey: .assetGeneration)
            self.path = try container.decode(String.self, forKey: .path)
            self.targetIds = try container.decodeIfPresent([String].self, forKey: .targets) ?? []
            self.order = try container.decodeIfPresent(Int.self, forKey: .order)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.assets, forKey: .assetGeneration)
            try container.encode(self.path, forKey: .path)
            if !self.targetIds.isEmpty { try container.encode(self.targetIds, forKey: .targets) }
            try container.encodeIfPresent(self.order, forKey: .order)
        }
    }
    
    public struct File: TemplateDefinition {
        public var type: Template.Definitions.Kind { return .assetGeneration }
        /// The path for the file/folder being described.
        public var path: String
        /// The visual position/order.
        public var order: Int?
        ///
        public var targets: [String]
        ///
        public var containsSubstitutionMacros: Bool
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.path = try container.decode(String.self, forKey: .path)
            self.order = try container.decodeIfPresent(Int.self, forKey: .order)
            self.targets = try container.decodeIfPresent([String].self, forKey: .targets) ?? []
            self.containsSubstitutionMacros = try container.decodeIfPresent(Bool.self, forKey: .substituionMacros) ?? false
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.path, forKey: .path)
            try container.encodeIfPresent(self.order, forKey: .order)
            if !self.targets.isEmpty { try container.encode(self.targets, forKey: .targets) }
            if self.containsSubstitutionMacros { try container.encode(true, forKey: .substituionMacros) }
        }
    }
    
    public struct Custom: TemplateDefinition {
        public var type: Template.Definitions.Kind { return .custom }
        /// The visual position/order.
        public var order: Int?
        ///
        public var targets: [String]
        ///
        public var end: String?
        ///
        public var buildAttributes: [String]
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.order = try container.decodeIfPresent(Int.self, forKey: .order)
            self.targets = try container.decodeIfPresent([String].self, forKey: .targets) ?? []
            self.end = try container.decodeIfPresent(String.self, forKey: .end)
            self.buildAttributes = try container.decodeIfPresent([String].self, forKey: .buildAttributes) ?? []
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.order, forKey: .order)
            if !self.targets.isEmpty { try container.encode(self.targets, forKey: .targets) }
            try container.encodeIfPresent(self.end, forKey: .end)
            if !self.buildAttributes.isEmpty { try container.encode(self.buildAttributes, forKey: .buildAttributes) }
        }
    }
}

extension Template.Definitions.AssetsCatalog {
    ///
    public struct Asset: Codable {
        /// The asset's given name.
        public var name: String
        /// The type of asset in the asset catalog.
        public var type: Kind
        /// The platforms where this asset is supported.
        public var platforms: Set<Platform>
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.type = try container.decode(Kind.self, forKey: .type)
            self.platforms = .init()
            guard container.contains(.platforms) else { return }
            
            let platforms = try container.nestedContainer(keyedBy: CommonCodingKey.self, forKey: .platforms)
            for key in platforms.allKeys {
                switch key.stringValue {
                case Platform.iOS.name: self.platforms.insert(.iOS)
                case Platform.macOS.name: self.platforms.insert(.macOS)
                case Platform.tvOS.name: self.platforms.insert(.tvOS)
                case Platform.watchOS.name: self.platforms.insert(.watchOS)
                default:
                    let value = try platforms.decode(String.self, forKey: key)
                    self.platforms.insert(.custom(key.stringValue, value: value))
                }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.type, forKey: .type)
            guard !self.platforms.isEmpty else { return }
            
            var subContainer = container.nestedContainer(keyedBy: CommonCodingKey.self, forKey: .platforms)
            for platform in self.platforms {
                guard let key = CommonCodingKey(stringValue: platform.name) else {
                    let ctx = EncodingError.Context(codingPath: subContainer.codingPath, debugDescription: "The platform name cannot be empty.")
                    throw EncodingError.invalidValue(platform, ctx)
                }
                try subContainer.encode(platform.value, forKey: key)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case name = "Name"
            case type = "Type"
            case platforms = "Platforms"
        }
    }
    
    /// The type of asset being generated.
    public enum Kind: RawRepresentable, Codable, Hashable {
        /// App icon for iOS, macOS, and watchOS applications.
        case appIcon
        /// App icon for tvOS applications.
        case appIconTV
        /// Launch image (usually for tvOS).
        case launchImage
        /// Custom asset in the asset catalog.
        case custom(String)
        
        public init?(rawValue: String) {
            guard !rawValue.isEmpty else { return nil }
            switch rawValue {
            case Kind.appIcon.rawValue: self = .appIcon
            case Kind.appIconTV.rawValue: self = .appIconTV
            case Kind.launchImage.rawValue: self = .launchImage
            default: self = .custom(rawValue)
            }
        }
        
        public var rawValue: String {
            switch self {
            case .appIcon: return "appicon"
            case .appIconTV: return "tvappicon"
            case .launchImage: return "launchimage"
            case .custom(let value): return value
            }
        }
    }
    
    public enum Platform: Hashable {
        case iOS
        case macOS
        case tvOS
        case watchOS
        case custom(String, value: String)
        
        public var name: String {
            switch self {
            case .iOS: return "iOS"
            case .macOS: return "macOS"
            case .tvOS: return "tvOS"
            case .watchOS: return "watchOS"
            case .custom(let name, _): return name
            }
        }
        
        public var value: String {
            switch self {
            case .iOS: return "___VARIABLE_iOSPlatform___"
            case .macOS: return "___VARIABLE_OSXPlatform___"
            case .tvOS: return "___VARIABLE_tvOSPlatform___"
            case .watchOS: return "___VARIABLE_watchOSPlatform___"
            case .custom(_, let value): return value
            }
        }
        
        public static func == (lhs: Platform, rhs: Platform) -> Bool {
            switch (lhs, rhs) {
            case (.iOS, .iOS), (.macOS, .macOS), (.tvOS, .tvOS), (.watchOS, .watchOS):
                return true
            case (.custom(let leftName, let leftValue), .custom(let rightName, let rightValue)):
                return (leftName == rightName) && (leftValue == rightValue)
            default:
                return false
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.name)
        }
    }
}

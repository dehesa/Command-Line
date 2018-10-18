import Foundation

public struct Template: Decodable {
    /// The type of template.
    public var kind: Kind
    /// Unique identifier (used in template subclassing).
    public var identifier: String?
    /// Subclasses for this template.
    public var ancestors: [String]
    /// Indication whether the template can be used through Xcode or it is used for subclassing.
    public var concrete: Bool
    
    /// Template name appearing on the template browser.
    public var name: String?
    ///
    public var title: String?
    /// A short description of this template.
    public var summary: String?
    /// A lengthy text description of what the template does.
    public var description: String?
    
    /// Platforms required by this template.
    public var platforms: [Platform]
    /// Targets created by this template.
    public var targets: [Target]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.kind = try container.decode(Kind.self, forKey: .kind)
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        self.ancestors = try container.decodeIfPresent([String].self, forKey: .ancestors) ?? []
        self.concrete = try container.decodeIfPresent(Bool.self, forKey: .concrete) ?? false
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        
        self.platforms = try container.decodeIfPresent([Platform].self, forKey: .platforms) ?? []
        self.targets = try container.decodeIfPresent([Target].self, forKey: .targets) ?? []
    }
}

extension Template {
    /// The extension for the template packages.
    public static let packageExtension = "xctemplate"
    /// The name of the Property List file representing the template.
    public static let plist = "TemplateInfo.plist"
    
    public enum Key: String, CodingKey {
        case kind = "Kind"
        case identifier = "Identifier"
        case ancestors = "Ancestors"
        case concrete = "Concrete"
        
        case name = "Name"
        case title = "Title"
        case summary = "Summary"
        case description = "Description"
        
        case platforms = "Platforms"
        case targets = "Targets"
        
        case targetOnly = "TargetOnly"
        case nodes = "Nodes"
        case definitions = "Definitions"
        case options = "Options"
        case optionConstraints = "OptionConstraints"
        case icon = "Icon"
        case order = "SortOrder"
        case project = "Project"
        case projectOnly = "ProjectOnly"
        case associatedTargetSpecification = "AssociatedTargetSpecification"
        case mainTemplateFile = "MainTemplateFile"
        case supportSuddenTermination = "NSSupportsSuddenTermination"
        case allowedTypes = "AllowedTypes"
        case components = "Components"
        case hiddenFromLibrary = "HiddenFromLibrary"
        case hiddenFromChooser = "HiddenFromChooser"
        case executables = "Executables"
        case buildableType = "BuildableType"
        case defaultCompletionName = "DefaultCompletionName"
    }
}

extension Template {
    /// The types of templates supported by Xcode.
    ///
    /// There are 138 templates within Xcode 10, of which:
    /// - 90 are project templates.
    /// - 34 are foundation file templates.
    /// - 7 are SpriteKit or SceneKit asset templates.
    /// - 4 are playground templates.
    /// - 1 is a Core Data template.
    /// - 1 is a Siri Intent template.
    /// - 1 is an Objective-C refactoring template.
    public enum Kind: String, Codable {
        /// Xcode project templates.
        case project = "Xcode.Xcode3.ProjectTemplateUnitKind"
        /// Xcode Foundation file templates (e.g. Swift, Objc, etc.)
        case file = "Xcode.IDEFoundation.TextSubstitutionFileTemplateKind"
        /// Xcode assets (e.g. SpriteKit Scene, Action, Particle, TileSet; or SceneKit Scene, Asset Catalog, Particle System).
        case asset = "Xcode.IDEKit.TextSubstitutionFileTemplateKind"
        /// Xcode playground (e.g. Map, Game, Single View, Blank).
        case playground = "Xcode.IDEFoundation.TextSubstitutionPlaygroundTemplateKind"
        /// Xcode Core Data files (e.g. NSManagedObject subclass).
        case coreData = "Xcode.IDECoreDataModeler.ManagedObjectTemplateKind"
        /// Xcode Siri intents files.
        case siri = "Xcode.IDEIntentBuilderEditor.IntentTemplateKind"
        /// Xcode refactoring template (e.g. new Objc superclass)
        case refactoring = "Xcode.IDEKit.RefactoringFileTemplateKind.NewSuperclass"
    }
}

extension Template {
    /// File types allowed to be used in templates.
    ///
    /// File types are identified through the [UTI (reverse-DNS)](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_conc/understand_utis_conc.html).
    public enum FileType: String, Codable {
        case swift = "public.swift-source"
        case c = "public.c-source"
        case cHeader = "public.c-header"
        case cHeaderPrecompiled = "public.precompiled-c-header"
        case cpp = "public.c-plus-plus-source"
        case cppHeader = "public.c-plus-plus-header"
        case cppHeaderPrecompiled = "public.precompiled-c-plus-plus-header"
        case objc = "public.objective-c-source"
        case objcpp = "public.objective-c-plus-plus-source"
        case sceneKitScene = "com.apple.scenekit.scene"
        case sceneKitParticles = "com.apple.scenekit.particlesystem"
        case sceneKitAssetCatalog = "com.apple.scenekit.assetcatalog"
        case spriteKitSerialized = "com.apple.spritekit.serialized"
        case playground = "com.apple.dt.playground"
        case playgroundPage = "com.apple.dt.playgroundpage"
    }
}

extension Template {
    /// Platforms supported by Xcode's templating system.
    public enum Platform: RawRepresentable, Codable {
        case macOS
        case iOS
        case watchOS
        case tvOS
        
        public init?(rawValue: String) {
            switch rawValue {
            case CodingKeys.macOS.rawValue: self = .macOS
            case CodingKeys.iOS.rawValue: self = .iOS
            case CodingKeys.watchOS.rawValue: self = .watchOS
            case CodingKeys.tvOS.rawValue,
                 CodingKeys.tvOS2.rawValue: self = .tvOS
            default: return nil
            }
        }
        
        public var rawValue: String {
            switch self {
            case .macOS:    return CodingKeys.macOS.rawValue
            case .iOS:      return CodingKeys.iOS.rawValue
            case .watchOS:  return CodingKeys.watchOS.rawValue
            case .tvOS:     return CodingKeys.tvOS.rawValue
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case macOS = "com.apple.platform.macosx"
            case iOS = "com.apple.platform.iphoneos"
            case watchOS = "com.apple.platform.watchos"
            case tvOS = "com.apple.platform.appletvos"
            case tvOS2 = "com.apple.platform.tvos"
        }
    }
}

extension Template {
    ///
    public enum Variable: String {
        ///
        case fileBaseName = "___FILEBASENAME___"
        
        static func +(lhs: Variable, rhs: String) -> String {
            return lhs.rawValue + rhs
        }
        
        static func +(lhs: String, rhs: Variable) -> String {
            return lhs + rhs.rawValue
        }
    }
}

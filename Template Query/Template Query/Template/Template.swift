import Foundation

public struct Template: Codable {
    /// The type of template.
    public var kind: Kind
    /// Unique identifier (used in template subclassing).
    public var identifier: String?
    /// Subclasses for this template.
    public var ancestors: [String]
    /// Indication whether the template is intended for subclassing or it can be displayed in Xcode.
    public var isAbstract: Bool
    
    /// Template name appearing on the template browser.
    public var name: String?
    // TODO: What is this?
    public var title: String?
    /// A short description of this template.
    public var summary: String?
    /// A lengthy description of what the template does.
    public var description: String?
    /// The template icon to be displayed in Xcode.
    ///
    /// Two icons with the name given in this property are expected; e.g. iconName.png (48x48) and iconName@2x.png (96x96).
    /// The icons shall be place in the folder of the generated PLIST.
    ///
    /// Some files seems to not have the icon name defined, but they do have icons named "TemplateIcon.png" (and the @2x version).
    /// Xcode recognizes the icon without probelms.
    public var icon: String?
    /// If defined, it overrides the alphabetical sort order in Xcode template chooser.
    public var order: Int?
    
    /// The default name displayed when creating a file
    public var completionName: String?
    /// The name (and extension) for the main file generated by the template.
    public var mainFileName: String?
    
    /// Platforms required by this template.
    public var platforms: [Platform]
    /// Targets created by this template.
    public var targets: [Target]
    ///
    public var isTargetOnly: Bool
    /// Allowed file types.
    public var supportedFileTypes: [FileType]
    
    ///
    public var definitions: Definitions
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.kind = try container.decode(Kind.self, forKey: .kind)
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        self.ancestors = try container.decodeIfPresent([String].self, forKey: .ancestors) ?? []
        let concrete = try container.decodeIfPresent(Bool.self, forKey: .concrete) ?? false
        self.isAbstract = !concrete
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        if let order = try container.decodeIfPresent(Int.self, forKey: .order) {
            self.order = order
        } else if let orderString = try container.decodeIfPresent(String.self, forKey: .order),
            let order = Int(orderString) {
            self.order = order
        }
        
        self.completionName = try container.decodeIfPresent(String.self, forKey: .defaultCompletionName)
        self.mainFileName = try container.decodeIfPresent(String.self, forKey: .mainTemplateFile)
        
        self.platforms = try container.decodeIfPresent([Platform].self, forKey: .platforms) ?? []
        self.targets = try container.decodeIfPresent([Target].self, forKey: .targets) ?? []
        self.isTargetOnly = try container.decodeIfPresent(Bool.self, forKey: .targetOnly) ?? false
        self.supportedFileTypes = try container.decodeIfPresent([FileType].self, forKey: .allowedFileTypes) ?? []
        
        self.definitions = try container.decodeIfPresent(Definitions.self, forKey: .definitions) ?? Definitions()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.kind, forKey: .kind)
        try container.encodeIfPresent(self.identifier, forKey: .identifier)
        if !self.ancestors.isEmpty { try container.encode(self.ancestors, forKey: .ancestors) }
        if !self.isAbstract { try container.encode(!self.isAbstract, forKey: .concrete) }
        
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.summary, forKey: .summary)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.icon, forKey: .icon)
        try container.encodeIfPresent(self.order, forKey: .order)
        
        if !self.platforms.isEmpty { try container.encode(self.platforms, forKey: .platforms) }
        if !self.targets.isEmpty { try container.encode(self.targets, forKey: .targets) }
        if self.isTargetOnly { try container.encode(self.isTargetOnly, forKey: .targetOnly) }
        
        try container.encodeIfPresent(self.completionName, forKey: .defaultCompletionName)
        try container.encodeIfPresent(self.mainFileName, forKey: .mainTemplateFile)
        try container.encodeIfPresent(self.supportedFileTypes, forKey: .allowedFileTypes)
        
        if !self.definitions.isEmpty { try container.encode(self.definitions, forKey: .definitions) }
    }
}

extension Template {
    /// The extension for the template packages.
    public static let packageExtension = "xctemplate"
    /// The name of the Property List file representing the template.
    public static let plist = "TemplateInfo.plist"
    
    private enum CodingKeys: String, CodingKey {
        case kind = "Kind"
        case identifier = "Identifier"
        case ancestors = "Ancestors"
        case concrete = "Concrete"
        
        case name = "Name"
        case title = "Title"
        case summary = "Summary"
        case description = "Description"
        case icon = "Icon"
        case order = "SortOrder"
        
        case defaultCompletionName = "DefaultCompletionName"
        case mainTemplateFile = "MainTemplateFile"
        
        case platforms = "Platforms"
        case targets = "Targets"
        case targetOnly = "TargetOnly"
        case allowedFileTypes = "AllowedTypes"
        
        case definitions = "Definitions"
        
        
        
        
        case nodes = "Nodes"
        case options = "Options"
        case optionConstraints = "OptionConstraints"
        case project = "Project"
        case projectOnly = "ProjectOnly"
        case associatedTargetSpecification = "AssociatedTargetSpecification"
        case components = "Components"
        case hiddenFromLibrary = "HiddenFromLibrary"
        case hiddenFromChooser = "HiddenFromChooser"
        case executables = "Executables"
        case buildableType = "BuildableType"
        case supportSuddenTermination = "NSSupportsSuddenTermination"
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

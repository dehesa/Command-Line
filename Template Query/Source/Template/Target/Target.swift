import Foundation

extension Template {
    /// Xcode project target definition.
    public struct Target: Codable {
        /// Unique identifier for the target.
        public var identifier: String?
        /// The name displayed on Xcode.
        public var name: String? = nil
        /// The type of target described (whether aggregate, legacy, or regular).
        public var type: Kind = .regular
        /// Whether this target should be considered abstract or not.
        public var isAbstract: Bool = false
        /// The type of product being built.
        public var productType: ProductType?
        /// For testing targets, this property point to the target identifier under test.
        public var targetIdUnderTest: String? = nil
        /// Build properties.
        public var build: Build
        
        /// Initializer setting up the default values for the target.
        /// - parameter identifier: Custom identifier (following the reverse DNS system) for the target (e.g. `io.dehesa.cmd.template.parser`).
        /// - parameter product: The type of product being built.
        public init(identifier: String?, product: ProductType?) {
            self.identifier = identifier
            self.productType = product
            self.build = Build()
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.type = try container.decodeIfPresent(Kind.self, forKey: .type) ?? .regular
            let isConcrete = try container.decodeIfPresent(Bool.self, forKey: .concrete) ?? true
            self.isAbstract = !isConcrete
            self.productType = try container.decodeIfPresent(ProductType.self, forKey: .productType)
            self.targetIdUnderTest = try container.decodeIfPresent(String.self, forKey: .targetIdToTest)
            
            self.build = try Build(from: decoder)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encodeIfPresent(self.identifier, forKey: .identifier)
            try container.encodeIfPresent(self.name, forKey: .name)
            if self.type != .regular { try container.encode(self.type, forKey: .type) }
            if self.isAbstract { try container.encode(false, forKey: .concrete) }
            try container.encodeIfPresent(self.productType, forKey: .productType)
            try container.encodeIfPresent(self.targetIdUnderTest, forKey: .targetIdToTest)
            
            try self.build.encode(to: encoder)
        }
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "TargetIdentifier"
            case name = "Name"
            case type = "TargetType"
            case concrete = "Concrete"
            case productType = "ProductType"
            case targetIdToTest = "TargetIdentifierToBeTested"
        }
    }
}

extension Template.Target {
    /// The type of target being described.
    public enum Kind: String, Codable, Equatable {
        case regular
        case aggregate = "Aggregate"
        case legacy = "Legacy"
    }
    
    /// The type of product being built.
    public enum ProductType: String, Codable {
        case app = "com.apple.product-type.application"
        case appExtension = "com.apple.product-type.app-extension"
        case appWatch = "com.apple.product-type.application.watchapp2"
        case watchKitExtension = "com.apple.product-type.watchkit2-extension"
        case bundle = "com.apple.product-type.bundle"
        case bundleTestingUniTest = "com.apple.product-type.bundle.ui-testing"
        case bundleTestingUI = "com.apple.product-type.bundle.unit-test"
        case framework = "com.apple.product-type.framework"
        case inAppPurchase = "com.apple.product-type.in-app-purchase-content"
        case instrumentsPackage = "com.apple.product-type.instruments-package"
        case kernelExtension = "com.apple.product-type.kernel-extension"
        case metalLibrary = "com.apple.product-type.metal-library"
        case tool = "com.apple.product-type.tool"
        case xcodeExtension = "com.apple.product-type.xcode-extension"
        case xpcService = "com.apple.product-type.xpc-service"
    }
}

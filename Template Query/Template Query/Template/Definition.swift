import Foundation


public protocol TemplateDefinition: Codable {
    ///
    var type: Template.Definitions.Kind { get }
}


extension Template {
    ///
    public struct Definitions: Codable {
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
                #warning("TODO: Figure out what type of definition it is.")
                if let raw = try? container.decode(Raw.self, forKey: key) {
                    self.specifications[key.stringValue] = raw
                } else if let container = try? container.decode(Container.self, forKey: key) {
                    self.specifications[key.stringValue] = container
                }
                
                guard let dictionary = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: key) else {
                    throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "The type given for this definition is invalid. Only strings and dictionaries are allowed.")
                }
                
                if dictionary.contains(.beginning) {
                    self.specifications[key.stringValue] = try Container(from: container.superDecoder(forKey: key))
                }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            
        }
        
        ///
        public var isEmpty: Bool {
            return true
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
    ///
    public enum Kind {
        ///
        case raw
        ///
        case container
    }
    
    ///
    public struct Raw: TemplateDefinition {
        public var type: Template.Definitions.Kind { return .raw }
        ///
        public var value: String
        
        public init(_ value: String) {
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(String.self)
        }
        
        public func encode(to encoder: Encoder) throws {
            
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
            
        }
    }

}

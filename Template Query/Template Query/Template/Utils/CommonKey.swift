import Foundation

/// Key for coding keys being of any type.
internal struct CommonCodingKey: CodingKey {
    private let value: String
    
    init?(stringValue: String) {
        guard !stringValue.isEmpty else { return nil }
        self.value = stringValue
    }
    
    init?(intValue: Int) {
        self.value = String(intValue)
    }
    
    var stringValue: String {
        return self.value
    }
    
    var intValue: Int? {
        return Int(self.value)
    }
}

/// Value on `Codable` where the type can only be a Boolean, Int, Double, or a String.
internal struct CoreCodingValue: Codable {
    let content: Any
    
    init?(_ value: Any) {
        switch value {
        case is Bool:   self.content = value
        case is Int:    self.content = value
        case is Double: self.content = value
        case is String: self.content = value
        default: return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let boolean = try? container.decode(Bool.self) {
            self.content = boolean
        } else if let integer = try? container.decode(Int.self) {
            self.content = integer
        } else if let number = try? container.decode(Double.self) {
            self.content = number
        } else if let string = try? container.decode(String.self) {
            if string == "YES" {
                self.content = true
            } else if string == "NO" {
                self.content = false
            } else if let integer = Int(string) {
                self.content = integer
            } else if let number = Double(string) {
                self.content = number
            } else {
                self.content = string
            }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "The setting value couldn't be decoded.")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.content {
        case let boolean as Bool:  try container.encode(boolean)
        case let integer as Int:   try container.encode(integer)
        case let number as Double: try container.encode(number)
        case let string as String: try container.encode(string)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "The setting value couldn't be encoded.")
            throw EncodingError.invalidValue(self.content, context)
        }
    }
}

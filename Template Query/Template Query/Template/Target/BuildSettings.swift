import Foundation

extension Template.Target.Build {
    #warning("TODO: Setting & Configurations")
    /// Build settings and configurations.
    public struct Settings: Codable, CustomStringConvertible {
        #warning("TODO")
        
        ///
        public init() {
            #warning("TODO")
        }
        
        public init(from decoder: Decoder) throws {
            #warning("TODO")
        }
        
        public func encode(to encoder: Encoder) throws {
            #warning("TODO")
        }
        
        public var description: String {
            #warning("TODO")
            return ""
        }
        
        ///
        public var isEmpty: Bool {
            #warning("TODO")
            return true
        }
        
        private enum CodingKeys: String, CodingKey {
            case settings = "SharedSettings"
            case configurations = "Configurations"
        }
    }
}

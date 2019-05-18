import Foundation

enum TemplatesPath: String {
    case xcode = "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates"
    case user = "~/Library/Developer/Xcode/Templates"
    
    var url: URL { return URL(fileURLWithPath: self.rawValue) }
}

// Template URLs.
let templateURLs = try! Detector.xcodeTemplateURLs(under: TemplatesPath.xcode.url)

// Retrieve all templates as PLISTs.
let files: [(url: URL, plist: [String:Any])] = templateURLs.map { ($0, try! Detector.plist(url: $0)) }

//var result = Set<String>()
var count = 0
for (url, plist) in files {
    guard let highlevel = plist["Definitions"] else { continue }
    
    for definition in highlevel as! [String:Any] {
        guard let value = definition.value as? [String:Any] else { continue }
        guard !value.contains(where: { (key, _) -> Bool in
            key == "Beginning" || key == "AssetGeneration" || key == "Path"
        }) else { continue }
        print(definition.key)
        print(definition.value)
        print()
//        print(value.keys.sorted().joined(separator: ", "))
    }
}
//print(Array(result).sorted().joined(separator: "\n"))







//let path = TemplatesPath.xcode.rawValue + "/Project Templates/CrossPlatform/watchOS Base" + ".xctemplate/TemplateInfo.plist"
//let url = URL(fileURLWithPath: path)
//
//let data = try Data(contentsOf: url)
//let watchOS = try PropertyListDecoder().decode(Template.self, from: data)

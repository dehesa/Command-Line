import Foundation

enum TemplatesPath: String {
    case xcode = "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates"
    case user = "~/Library/Developer/Xcode/Templates"
    
    var url: URL { return URL(fileURLWithPath: self.rawValue) }
}

//let templateURLs = try! Detector.xcodeTemplateURLs(under: TemplatesPath.xcode.url)

// Retrieve all templates as PLISTs.
//let files: [(url: URL, plist: [String:Any])] = templateURLs.map { ($0, try! Detector.plist(url: $0)) }

//let templates: [(url: URL, template: Template)] = templateURLs.map { ($0, try! Detector.xcodeTemplate(url: $0)) }
//for template in templates {
//    let targets = template.template.targets
//    guard !targets.isEmpty else { continue }
//
//    for target in targets {
//        print(target)
//    }
//}

typealias Plan = Template.Target.Build.Plan
var plan = Template.Target.Build.Plan()
plan.append(Plan.Headers())
plan.append(Plan.Sources())
plan.append(Plan.Resources())
plan.append(Plan.Frameworks())
plan.append(Plan.Files(destination: .absolutePath, path: "/Manolo"))
plan.append(Plan.Script(programURL: "/bin/shell", script: "Jimena"))

let encoder = PropertyListEncoder()
encoder.outputFormat = .xml
let encodedData = try encoder.encode(plan)
let encodedRepresentation = String(data: encodedData, encoding: .utf8)!
print(encodedRepresentation)

let decoder = PropertyListDecoder()
let decodedValue = try decoder.decode(Plan.self, from: encodedData)
print(decodedValue.description)

//for file in files {
//    guard let platforms = file.plist["Platforms"] as? [String], !platforms.isEmpty else { continue }
//    print(Sanitizer.curateURL(file.url, prefix: .xcode))
//    print(platforms)
//    print()
//}


//let templates: [(url: URL, plist: [String:Any])] = {
//    let urls = try! Detector.xcodeTemplateURLs(under: TemplatesPath.xcode.url)
//    return urls.map { ($0, try! Detector.plist(url: $0)) }
//}()

// Retrieve all templates as Template instances.
//let templates: [(url: URL, template: Template)] = {
//
//}

//
//for template in templates {
//    guard let targets = template.plist[Template.Key.targets.rawValue] as? [[String:Any]] else { continue }
//
//    for target in targets {
//        print(Sanitizer.curateURL(template.url, prefix: .xcode))
//        print(Sanitizer.representation(target, indentationLevel: 0))
//        print()
//    }
//}

//for template in templates {
//    let url = Sanitizer.curateURL(template.url, prefix: .xcode)
//    if url.contains("iOS") {
//        print(url)
//    }
//}

//let path = TemplatesPath.xcode.rawValue + "/Project Templates/Base/Metal Library Base" + ".xctemplate/TemplateInfo.plist"
//let url = URL(fileURLWithPath: path)
//
//let data = try Data(contentsOf: url)
//let manolo = try PropertyListDecoder().decode(Template.self, from: data)
//print(manolo)


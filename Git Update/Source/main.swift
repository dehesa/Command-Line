import Foundation

let targetURL = Sanitizer.parse(arguments: CommandLine.arguments)
let projectURLs = Detector.gitProjects(from: targetURL).sorted {
    let components: (left: [String], right: [String]) = ($0.pathComponents, $1.pathComponents)
    
    for (left, right) in zip(components.left, components.right) {
        guard left != right else { continue }
        return left < right
    }
    
    return components.left.count < components.right.count
}

let total = projectURLs.count
CommandLine.write(to: .stdout, "\(total) git projects will be updated...\n\n")

for (index, url) in projectURLs.enumerated() {
    CommandLine.write(to: .stdout, "---------------------------------------------\n[\(index+1) of \(total)]: \(url.lastPathComponent)\n")
    Updater.update(project: url)
    CommandLine.write(to: .stdout, "\n\n")
}

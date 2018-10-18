import Foundation

/// Namespace for the update functions.
enum Updater {
    /// Updates the git project passed with the URL.
    /// - parameter url: The file URL of the targeted git project folder.
    static func update(project url: URL) {
        let task = Process()
        task.currentDirectoryURL = url
        task.launchPath = "/usr/local/bin/git"
        task.arguments = ["pull", "--tags"]
        task.launch()
        task.waitUntilExit()
    }
}

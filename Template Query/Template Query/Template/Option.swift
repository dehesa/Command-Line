import Foundation

extension Template {
    ///
    enum VisualOption: String, Codable {
        /// Displays a label (the user cannot perform any action on it).
        case label = "static"
        /// Displays a text field for the user to input a String value.
        case textField = "text"
        /// Displays a text field where the user can input a subclass (an optional popup can be display when the user clicks on the "expand" arrow.
        case subclassField = "class"
        /// Displays a popup where the user needs to select one single value among many.
        case popupSelector = "popup"
        /// Displays a checkbox for the user to tick/untick.
        case checkbox
    }
}

protocol TemplateOption {
    var identifier: String { get }
    var description: String { get }
    var type: Template.VisualOption { get }
}

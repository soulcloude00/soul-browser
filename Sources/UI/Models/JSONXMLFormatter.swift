import Foundation

/// JSON/XML Visual Formatter & Parser (Roadmap Item 53)
/// Catches raw JSON or XML pages, parsing and presenting them in an
/// interactive, collapsible tree view.
final class JSONXMLFormatter {
    static let shared = JSONXMLFormatter()

    private init() {}

    func detectAndFormat(content: String, mimeType: String?) -> FormattedTree? {
        if mimeType?.contains("json") == true || content.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{") {
            return parseJSON(content)
        }
        if mimeType?.contains("xml") == true || content.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") {
            return parseXML(content)
        }
        return nil
    }

    func parseJSON(_ string: String) -> FormattedTree? {
        guard let data = string.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        return FormattedTree(title: "JSON", root: buildNode(from: json, key: "root"))
    }

    func parseXML(_ string: String) -> FormattedTree? {
        guard let data = string.data(using: .utf8) else { return nil }
        let parser = SimpleXMLParser()
        return parser.parse(data)
    }

    private func buildNode(from value: Any, key: String) -> FormattedTree.Node {
        switch value {
        case let dict as [String: Any]:
            return .object(key: key, children: dict.map { buildNode(from: $0.value, key: $0.key) })
        case let array as [Any]:
            return .array(key: key, children: array.enumerated().map { buildNode(from: $0.element, key: "[\($0.offset)]") })
        case let string as String:
            return .string(key: key, value: string)
        case let number as NSNumber:
            return .number(key: key, value: number)
        case let bool as Bool:
            return .bool(key: key, value: bool)
        default:
            return .null(key: key)
        }
    }
}

struct FormattedTree {
    let title: String
    let root: Node

    enum Node {
        case object(key: String, children: [Node])
        case array(key: String, children: [Node])
        case string(key: String, value: String)
        case number(key: String, value: NSNumber)
        case bool(key: String, value: Bool)
        case null(key: String)
    }
}

private class SimpleXMLParser: NSObject, XMLParserDelegate {
    private var stack: [FormattedTree.Node] = []
    private var currentElement: String = ""
    private var currentText: String = ""

    func parse(_ data: Data) -> FormattedTree? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        return parser.parse() ? FormattedTree(title: "XML", root: .object(key: "root", children: stack)) : nil
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        let node: FormattedTree.Node = trimmed.isEmpty ? .null(key: elementName) : .string(key: elementName, value: trimmed)
        stack.append(node)
    }
}

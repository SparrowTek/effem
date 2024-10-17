//
//  XMLParser.swift
//  Effem
//
//  Created by Thomas Rademaker on 10/17/24.
//

import Foundation

protocol FMXMLNode: Sendable {
    var XML: String { get }
}

protocol FMXMLContainer: FMXMLNode {
    var childNodes: [any FMXMLNode] { get }
}

struct FMXMLDocument: FMXMLContainer {
    let documentElement: FMXMLElement
    var childNodes: [any FMXMLNode] { [documentElement] }
    var XML: String { documentElement.documentXML }
    
    init(_ rootElement: FMXMLElement) {
        documentElement = rootElement
    }
}

struct FMXMLElement: FMXMLNode, FMXMLContainer {
    let name: String
    let childNodes: [any FMXMLNode]
    private let attributes: [String: String]
    fileprivate let normalizedName: String
    
    init(_ name: String, attributes: [String: String] = [:], @FMXMLBuilder childNodes: () -> [any FMXMLNode] = { [] }) {
        self.init(name, attributes: attributes, childNodes: childNodes())
    }
    
    init(_ name: String, attributes: [String: String] = [:], childNodes: [any FMXMLNode]) {
        self.name = name
        self.normalizedName = Self.normalizeName(name)
        self.attributes = Self.normalizeAttributes(attributes)
        self.childNodes = childNodes
    }
    
    func attribute(_ attributeName: String) -> String? {
        attributes[FMXMLElement.normalizeName(attributeName)]
    }
    
    var documentXML: String { "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\(XML)" }
    
    var XML: String {
        var xml = "<\(name)"
        
        if !attributes.isEmpty {
            xml += " " + attributes.map { "\($0.fmXMLEntityEncoded)=\"\($1.fmXMLEntityEncoded)\"" }.joined(separator: " ")
        }
        
        // content
        let encodedChildren = childNodes.map { $0.XML }.joined()
        if !encodedChildren.isEmpty {
            xml += ">\(encodedChildren)</\(name)>"
        } else {
            xml += "/>"
        }
        
        return xml
    }
    
    fileprivate static func normalizeName(_ name: String) -> String {
        name.lowercased()
    }
    
    private static func normalizeAttributes(_ attributes: [String: String]) -> [String: String] {
        attributes.reduce([String: String]()) {
            var d = $0
            d[normalizeName($1.key)] = $1.value
            return d
        }
    }
}

fileprivate extension String {
    var fmXMLEntityEncoded: String {
        var xml = replacingOccurrences(of: "&" , with: "&amp;",  options: .literal)
        xml = xml.replacingOccurrences(of: "<" , with: "&lt;",   options: .literal)
        xml = xml.replacingOccurrences(of: ">" , with: "&gt;",   options: .literal)
        xml = xml.replacingOccurrences(of: "\"", with: "&quot;", options: .literal)
        xml = xml.replacingOccurrences(of: "'" , with: "&apos;", options: .literal)
        xml = xml.replacingOccurrences(of: "\n", with: "&#10;",  options: .literal)
        return xml
    }
}

// Strings are used as children directly for text (instead of having separate Text nodes)
extension String: FMXMLNode {
    var XML: String { fmXMLEntityEncoded }
    var textValue: String { self }
}

struct FMXMLDocumentFragment: FMXMLContainer {
    var childNodes: [any FMXMLNode]
    var XML: String { childNodes.map { $0.XML }.joined() }
}

@resultBuilder
struct FMXMLBuilder {
    static func buildBlock(_ components: any FMXMLNode...) -> [any FMXMLNode]    {
        components
    }
    
    static func buildEither(first components: [any FMXMLNode]) -> any FMXMLNode  {
        FMXMLDocumentFragment(childNodes: components)
    }
    
    static func buildEither(second components: [any FMXMLNode]) -> any FMXMLNode {
        FMXMLDocumentFragment(childNodes: components)
    }
    
    static func buildArray(_ components: [[any FMXMLNode]]) -> any FMXMLNode     {
        FMXMLDocumentFragment(childNodes: components.flatMap { $0 })
    }
    
    static func buildExpression(_ expression: any FMXMLNode) -> any FMXMLNode    {
        FMXMLDocumentFragment(childNodes: [expression])
    }
    
    static func buildExpression(_ expression: [any FMXMLNode]) -> any FMXMLNode  {
        FMXMLDocumentFragment(childNodes: expression)
    }
    
    static func buildOptional(_ components: [any FMXMLNode]?) -> any FMXMLNode   {
        FMXMLDocumentFragment(childNodes: components ?? [])
    }
}


// MARK: - Optional add-on: Querying

extension FMXMLNode {
    var textValue: String {
        if let string = self as? String {
            string
        }
        else if let container = self as? FMXMLContainer {
            container.childNodes.map { ($0 as? String) ?? "" }.joined()
        }
        else {
            ""
        }
    }
}

extension FMXMLElement {
    fileprivate func attribute(normalizedAttributeName: String) -> String? { attributes[normalizedAttributeName] }
}

extension FMXMLContainer {
    var childElements: [FMXMLElement] { childNodes.compactMap { $0 as? FMXMLElement } }
    
    var allDescendants: [FMXMLElement] {
        childElements + childElements.flatMap { $0.allDescendants }
    }
    
    func childElements(named elementName: String) -> [FMXMLElement] {
        childElements.filter { $0.normalizedName == FMXMLElement.normalizeName(elementName) }
    }
    
    func firstChild(named elementName: String) -> FMXMLElement? { childElements(named: elementName).first }
    
    func allDescendants(named elementName: String) -> [FMXMLElement] {
        allDescendants.filter { $0.normalizedName == FMXMLElement.normalizeName(elementName) } // TODO: marco has == elementName but also created the normalizeName property??
    }
    
    func allDescendantAttributeValues(named attributeName: String) -> [String] {
        allDescendants.compactMap { $0.attribute(normalizedAttributeName: FMXMLElement.normalizeName(attributeName)) }
    }
    
    var textValue: String { childNodes.map { ($0 as? String) ?? "" }.joined() }
    
    // Supports VERY basic XPath queries, e.g. "//item/enclosure/@url"
    func queryElements(_ xPath: String) -> [FMXMLElement] { query(xPath).compactMap { $0 as? FMXMLElement } }
    func queryStrings(_ xPath: String) -> [String] { query(xPath).map { $0.textValue } }
    func query(_ xPath: String) -> [any FMXMLNode] {
        let scanner = Scanner(string: xPath)
        var contexts: [FMXMLNode] = [self]
        while !scanner.isAtEnd {
            var nextContexts: [FMXMLNode] = []
            
            if scanner.scanString("//") != nil {
                if scanner.scanString("@") != nil, let attributeName = scanner.scanUpToString("/") {
                    nextContexts = contexts.compactMap { $0 as? FMXMLContainer }.flatMap { $0.allDescendantAttributeValues(named: attributeName) }
                } else if let name = scanner.scanUpToString("/") {
                    nextContexts = contexts.compactMap { $0 as? FMXMLContainer }.flatMap { $0.allDescendants(named: name) }
                }
            } else if scanner.scanString("/") != nil {
                if scanner.scanString("@") != nil, let attributeName = scanner.scanUpToString("/") {
                    nextContexts = contexts.compactMap { $0 as? FMXMLElement }.compactMap { $0.attribute(attributeName) }
                } else if let name = scanner.scanUpToString("/") {
                    nextContexts = contexts.compactMap { $0 as? FMXMLContainer }.flatMap { $0.childElements(named: name) }
                }
            } else {
                fatalError("Unrecognized XPath syntax: \(xPath)")
            }
            
            contexts = nextContexts
        }
        return contexts
    }
}


// MARK: - Optional add-on: XML parsing
// A VERY simple parser that doesn't support namespaces and performs no real error handling.

extension FMXMLDocument {
    init?(xml: String) {
        guard let data = xml.data(using: .utf8) else { return nil }
        let delegate = FMXMLParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        
        guard let rootElement = delegate.xmlNode as? FMXMLElement else { return nil }
        documentElement = rootElement
    }
}

fileprivate class FMXMLReadingNode {
    fileprivate enum NodeType {
        case element(name: String, attributes: [String: String])
        case text(content: String)
    }
    
    let type: NodeType
    var childNodes: [FMXMLReadingNode] = []
    weak var parentNode: FMXMLReadingNode? = nil
    
    init(text: String) { self.type = .text(content: text) }
    init(name: String, attributes: [String: String]) { self.type = .element(name: name, attributes: attributes) }
    
    var xmlNode: any FMXMLNode {
        switch type {
        case .element(let name, let attributes): FMXMLElement(name, attributes: attributes, childNodes: childNodes.map { $0.xmlNode })
        case .text(let content): content
        }
    }
}

fileprivate class FMXMLParserDelegate : NSObject, XMLParserDelegate {
    private var rootElement: FMXMLReadingNode? = nil
    private var inProgressElement: FMXMLReadingNode? = nil
    
    var xmlNode: (any FMXMLNode)? { rootElement?.xmlNode }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let newElement = FMXMLReadingNode(name: elementName, attributes: attributeDict)
        newElement.parentNode = inProgressElement
        inProgressElement?.childNodes.append(newElement)
        self.inProgressElement = newElement
        if rootElement == nil { rootElement = newElement }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        inProgressElement = inProgressElement?.parentNode
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        inProgressElement?.childNodes.append(FMXMLReadingNode(text: string))
    }
}

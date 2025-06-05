//
//  ClipboardItem.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import Foundation
import SwiftUI

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let type: ClipboardItemType
    let language: ProgrammingLanguage
    
    var displayTitle: String {
        let lines = content.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return firstLine.isEmpty ? "Empty snippet" : String(firstLine.prefix(50))
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum ClipboardItemType: String, Codable, CaseIterable {
    case text = "text"
    case code = "code"
    case url = "url"
    case email = "email"
    
    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .code: return "curlybraces"
        case .url: return "link"
        case .email: return "envelope"
        }
    }
    
    var color: Color {
        switch self {
        case .text: return .blue
        case .code: return .green
        case .url: return .orange
        case .email: return .purple
        }
    }
}

enum ProgrammingLanguage: String, Codable, CaseIterable {
    case swift = "swift"
    case javascript = "javascript"
    case typescript = "typescript"
    case python = "python"
    case java = "java"
    case kotlin = "kotlin"
    case cpp = "cpp"
    case c = "c"
    case csharp = "csharp"
    case go = "go"
    case rust = "rust"
    case php = "php"
    case ruby = "ruby"
    case html = "html"
    case css = "css"
    case scss = "scss"
    case json = "json"
    case xml = "xml"
    case sql = "sql"
    case bash = "bash"
    case zsh = "zsh"
    case powershell = "powershell"
    case dockerfile = "dockerfile"
    case yaml = "yaml"
    case toml = "toml"
    case markdown = "markdown"
    case latex = "latex"
    case plain = "plain"
    
    var displayName: String {
        switch self {
        case .swift: return "Swift"
        case .javascript: return "JavaScript"
        case .typescript: return "TypeScript"
        case .python: return "Python"
        case .java: return "Java"
        case .kotlin: return "Kotlin"
        case .cpp: return "C++"
        case .c: return "C"
        case .csharp: return "C#"
        case .go: return "Go"
        case .rust: return "Rust"
        case .php: return "PHP"
        case .ruby: return "Ruby"
        case .html: return "HTML"
        case .css: return "CSS"
        case .scss: return "SCSS"
        case .json: return "JSON"
        case .xml: return "XML"
        case .sql: return "SQL"
        case .bash: return "Bash"
        case .zsh: return "Zsh"
        case .powershell: return "PowerShell"
        case .dockerfile: return "Dockerfile"
        case .yaml: return "YAML"
        case .toml: return "TOML"
        case .markdown: return "Markdown"
        case .latex: return "LaTeX"
        case .plain: return "Plain Text"
        }
    }
    
    var color: Color {
        switch self {
        case .swift: return .orange
        case .javascript: return .yellow
        case .typescript: return .blue
        case .python: return .green
        case .java: return .red
        case .kotlin: return .purple
        case .cpp, .c: return .gray
        case .csharp: return .blue
        case .go: return .cyan
        case .rust: return .orange
        case .php: return .indigo
        case .ruby: return .red
        case .html: return .orange
        case .css: return .blue
        case .scss: return .pink
        case .json: return .green
        case .xml: return .purple
        case .sql: return .cyan
        case .bash, .zsh: return .black
        case .powershell: return .blue
        case .dockerfile: return .blue
        case .yaml: return .pink
        case .toml: return .brown
        case .markdown: return .indigo
        case .latex: return .green
        case .plain: return .secondary
        }
    }
    
    static func detectLanguage(from content: String) -> ProgrammingLanguage {
        let lowercased = content.lowercased()
        let lines = content.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Dockerfile detection
        if firstLine.hasPrefix("from ") || content.contains("FROM ") || content.contains("RUN ") {
            return .dockerfile
        }
        
        // Shebang detection
        if firstLine.hasPrefix("#!/") {
            if firstLine.contains("python") { return .python }
            if firstLine.contains("node") { return .javascript }
            if firstLine.contains("bash") { return .bash }
            if firstLine.contains("zsh") { return .zsh }
            if firstLine.contains("sh") { return .bash }
            if firstLine.contains("ruby") { return .ruby }
            if firstLine.contains("php") { return .php }
        }
        
        // Swift detection
        if lowercased.contains("import swiftui") || 
           lowercased.contains("import foundation") ||
           (lowercased.contains("func ") && lowercased.contains("var ")) ||
           (lowercased.contains("struct ") && lowercased.contains(": view")) ||
           lowercased.contains("@state") || lowercased.contains("@binding") {
            return .swift
        }
        
        // TypeScript detection (check before JavaScript)
        if lowercased.contains("interface ") || 
           lowercased.contains(": string") || 
           lowercased.contains(": number") ||
           lowercased.contains("type ") && lowercased.contains(" = ") ||
           lowercased.contains("export interface") {
            return .typescript
        }
        
        // JavaScript detection
        if lowercased.contains("function ") || 
           lowercased.contains("const ") || 
           lowercased.contains("let ") && lowercased.contains("=>") ||
           lowercased.contains("console.log") ||
           lowercased.contains("require(") ||
           lowercased.contains("module.exports") {
            return .javascript
        }
        
        // Python detection
        if lowercased.contains("def ") || 
           lowercased.contains("import ") && (lowercased.contains("print(") || lowercased.contains("from ")) ||
           lowercased.contains("if __name__") ||
           lowercased.contains("elif ") ||
           content.contains("    ") && lowercased.contains("def ") { // Python indentation
            return .python
        }
        
        // Java detection
        if lowercased.contains("public class ") ||
           lowercased.contains("public static void main") ||
           lowercased.contains("import java.") ||
           (lowercased.contains("public ") && lowercased.contains("class ")) {
            return .java
        }
        
        // Kotlin detection
        if lowercased.contains("fun ") ||
           lowercased.contains("class ") && lowercased.contains(" : ") ||
           lowercased.contains("data class ") ||
           lowercased.contains("import kotlin.") {
            return .kotlin
        }
        
        // C# detection
        if lowercased.contains("using system") ||
           lowercased.contains("namespace ") ||
           lowercased.contains("public class ") && lowercased.contains("{") ||
           lowercased.contains("static void main") {
            return .csharp
        }
        
        // C++ detection
        if lowercased.contains("#include <iostream>") ||
           lowercased.contains("std::") ||
           lowercased.contains("using namespace std") ||
           (lowercased.contains("#include") && lowercased.contains(".h")) {
            return .cpp
        }
        
        // C detection
        if lowercased.contains("#include <stdio.h>") ||
           lowercased.contains("printf(") ||
           lowercased.contains("int main()") {
            return .c
        }
        
        // Go detection
        if lowercased.contains("package main") ||
           lowercased.contains("func main()") ||
           lowercased.contains("import \"fmt\"") ||
           lowercased.contains("fmt.print") {
            return .go
        }
        
        // Rust detection
        if lowercased.contains("fn main()") ||
           lowercased.contains("use std::") ||
           lowercased.contains("println!") ||
           lowercased.contains("let mut ") {
            return .rust
        }
        
        // PHP detection
        if lowercased.contains("<?php") ||
           firstLine.contains("<?php") ||
           lowercased.contains("echo ") ||
           lowercased.contains("$_") {
            return .php
        }
        
        // Ruby detection
        if lowercased.contains("puts ") ||
           lowercased.contains("def ") && lowercased.contains("end") ||
           lowercased.contains("require '") ||
           lowercased.contains("class ") && lowercased.contains("end") {
            return .ruby
        }
        
        // HTML detection
        if lowercased.contains("<!doctype html") || 
           lowercased.contains("<html") ||
           (lowercased.contains("<div") && lowercased.contains("</div>")) ||
           (lowercased.contains("<head>") && lowercased.contains("</head>")) {
            return .html
        }
        
        // SCSS detection (check before CSS)
        if lowercased.contains("$") && lowercased.contains(":") ||
           lowercased.contains("@mixin") ||
           lowercased.contains("@include") {
            return .scss
        }
        
        // CSS detection
        if lowercased.contains("{") && lowercased.contains("}") && 
           (lowercased.contains("color:") || lowercased.contains("margin:") || lowercased.contains("padding:") || lowercased.contains("display:")) {
            return .css
        }
        
        // JSON detection
        if (lowercased.hasPrefix("{") && lowercased.hasSuffix("}")) ||
           (lowercased.hasPrefix("[") && lowercased.hasSuffix("]")) {
            // Additional JSON validation
            if lowercased.contains("\"") && (lowercased.contains(":") || lowercased.contains(",")) {
                return .json
            }
        }
        
        // XML detection
        if lowercased.hasPrefix("<?xml") ||
           (lowercased.contains("<") && lowercased.contains(">") && lowercased.contains("</")) {
            return .xml
        }
        
        // SQL detection
        if lowercased.contains("select ") || 
           lowercased.contains("insert into") ||
           lowercased.contains("create table") ||
           lowercased.contains("update ") && lowercased.contains(" set ") ||
           lowercased.contains("delete from") {
            return .sql
        }
        
        // YAML detection
        if content.contains("---") ||
           content.contains("  ") && content.contains(":") && !content.contains("{") ||
           lines.contains(where: { $0.matches(regex: "^[a-zA-Z_]+:\\s*$") }) {
            return .yaml
        }
        
        // TOML detection
        if content.contains("[") && content.contains("]") && content.contains("=") ||
           lowercased.contains("[dependencies]") ||
           lowercased.contains("[package]") {
            return .toml
        }
        
        // Markdown detection
        if content.contains("# ") ||
           content.contains("## ") ||
           content.contains("```") ||
           content.contains("*") && content.contains("*") ||
           content.contains("[") && content.contains("](") {
            return .markdown
        }
        
        // LaTeX detection
        if content.contains("\\documentclass") ||
           content.contains("\\begin{") ||
           content.contains("\\end{") ||
           content.contains("\\usepackage") {
            return .latex
        }
        
        // PowerShell detection
        if lowercased.contains("get-") ||
           lowercased.contains("set-") ||
           lowercased.contains("$_") ||
           lowercased.contains("write-host") {
            return .powershell
        }
        
        return .plain
    }
}

// MARK: - String Extension for Regex Matching

extension String {
    func matches(regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return !results.isEmpty
        } catch {
            return false
        }
    }
}
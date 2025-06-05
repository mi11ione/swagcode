//
//  SyntaxHighlighter.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import SwiftUI
import Foundation

struct SyntaxHighlightedText: View {
    let content: String
    let language: ProgrammingLanguage
    
    var body: some View {
        Text(highlightedContent)
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
    }
    
    private var highlightedContent: AttributedString {
        let highlighter = SyntaxHighlighter(language: language)
        return highlighter.highlight(content)
    }
}

class SyntaxHighlighter {
    private let language: ProgrammingLanguage
    
    init(language: ProgrammingLanguage) {
        self.language = language
    }
    
    func highlight(_ code: String) -> AttributedString {
        var attributedString = AttributedString(code)
        
        switch language {
        case .swift:
            highlightSwift(&attributedString)
        case .javascript:
            highlightJavaScript(&attributedString)
        case .typescript:
            highlightTypeScript(&attributedString)
        case .python:
            highlightPython(&attributedString)
        case .java:
            highlightJava(&attributedString)
        case .kotlin:
            highlightKotlin(&attributedString)
        case .cpp:
            highlightCpp(&attributedString)
        case .c:
            highlightC(&attributedString)
        case .csharp:
            highlightCSharp(&attributedString)
        case .go:
            highlightGo(&attributedString)
        case .rust:
            highlightRust(&attributedString)
        case .php:
            highlightPHP(&attributedString)
        case .ruby:
            highlightRuby(&attributedString)
        case .json:
            highlightJSON(&attributedString)
        case .html:
            highlightHTML(&attributedString)
        case .css:
            highlightCSS(&attributedString)
        case .scss:
            highlightSCSS(&attributedString)
        case .sql:
            highlightSQL(&attributedString)
        case .bash, .zsh:
            highlightBash(&attributedString)
        case .powershell:
            highlightPowerShell(&attributedString)
        case .yaml:
            highlightYAML(&attributedString)
        case .toml:
            highlightTOML(&attributedString)
        case .markdown:
            highlightMarkdown(&attributedString)
        case .dockerfile:
            highlightDockerfile(&attributedString)
        default:
            break
        }
        
        return attributedString
    }
    
    private func highlightSwift(_ attributedString: inout AttributedString) {
        let keywords = ["import", "class", "struct", "enum", "protocol", "func", "var", "let", "if", "else", "for", "while", "switch", "case", "default", "return", "private", "public", "internal", "static", "override", "init", "deinit", "extension", "mutating", "nonmutating", "lazy", "weak", "unowned", "optional", "required", "convenience", "dynamic", "final", "indirect", "prefix", "postfix", "operator", "precedencegroup", "associatedtype", "typealias", "subscript", "willSet", "didSet", "get", "set", "inout", "throws", "rethrows", "defer", "guard", "where", "as", "is", "try", "catch", "throw", "async", "await", "actor"]
        
        let types = ["String", "Int", "Double", "Float", "Bool", "Array", "Dictionary", "Set", "Optional", "Result", "Error", "Any", "AnyObject", "Void", "Never", "Self", "Type", "Protocol", "Class"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightKeywords(types, in: &attributedString, color: .blue)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightJavaScript(_ attributedString: inout AttributedString) {
        let keywords = ["function", "var", "let", "const", "if", "else", "for", "while", "do", "switch", "case", "default", "return", "break", "continue", "try", "catch", "finally", "throw", "new", "this", "typeof", "instanceof", "in", "of", "class", "extends", "super", "static", "async", "await", "yield", "import", "export", "from", "as", "default"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightPython(_ attributedString: inout AttributedString) {
        let keywords = ["def", "class", "if", "elif", "else", "for", "while", "try", "except", "finally", "with", "as", "import", "from", "return", "yield", "break", "continue", "pass", "raise", "assert", "del", "global", "nonlocal", "lambda", "and", "or", "not", "in", "is", "True", "False", "None"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "#")
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightJSON(_ attributedString: inout AttributedString) {
        highlightStrings(in: &attributedString)
        highlightNumbers(in: &attributedString)
        highlightKeywords(["true", "false", "null"], in: &attributedString, color: .orange)
    }
    
    private func highlightHTML(_ attributedString: inout AttributedString) {
        highlightHTMLTags(in: &attributedString)
        highlightStrings(in: &attributedString)
    }
    
    private func highlightCSS(_ attributedString: inout AttributedString) {
        highlightCSSProperties(in: &attributedString)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "/*", commentSuffix: "*/")
    }
    
    private func highlightKeywords(_ keywords: [String], in attributedString: inout AttributedString, color: Color) {
        let content = String(attributedString.characters)
        
        for keyword in keywords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
                
                for match in matches.reversed() {
                    if let range = Range(match.range, in: content) {
                        let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                        attributedString[attributedRange].foregroundColor = color
                        attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                    }
                }
            }
        }
    }
    
    private func highlightStrings(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let patterns = ["\"[^\"]*\"", "'[^']*'", "`[^`]*`"]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
                
                for match in matches.reversed() {
                    if let range = Range(match.range, in: content) {
                        let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                        attributedString[attributedRange].foregroundColor = .green
                    }
                }
            }
        }
    }
    
    private func highlightComments(in attributedString: inout AttributedString, commentPrefix: String = "//", commentSuffix: String? = nil) {
        let content = String(attributedString.characters)
        let pattern: String
        
        if let suffix = commentSuffix {
            pattern = "\(NSRegularExpression.escapedPattern(for: commentPrefix)).*?\(NSRegularExpression.escapedPattern(for: suffix))"
        } else {
            pattern = "\(NSRegularExpression.escapedPattern(for: commentPrefix)).*$"
        }
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .secondary
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).italic()
                }
            }
        }
    }
    
    private func highlightNumbers(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "\\b\\d+(\\.\\d+)?\\b"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .cyan
                }
            }
        }
    }
    
    private func highlightHTMLTags(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "<[^>]+>"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .blue
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                }
            }
        }
    }
    
    private func highlightCSSProperties(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "\\b[a-zA-Z-]+(?=\\s*:)"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .purple
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Additional Language Highlighting Methods
    
    private func highlightTypeScript(_ attributedString: inout AttributedString) {
        let keywords = ["function", "var", "let", "const", "if", "else", "for", "while", "do", "switch", "case", "default", "return", "break", "continue", "try", "catch", "finally", "throw", "new", "this", "typeof", "instanceof", "in", "of", "class", "extends", "super", "static", "async", "await", "yield", "import", "export", "from", "as", "default", "interface", "type", "enum", "namespace", "declare", "abstract", "implements", "readonly", "private", "public", "protected"]
        
        let types = ["string", "number", "boolean", "object", "undefined", "null", "any", "void", "never", "unknown"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightKeywords(types, in: &attributedString, color: .blue)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightJava(_ attributedString: inout AttributedString) {
        let keywords = ["abstract", "assert", "break", "case", "catch", "class", "const", "continue", "default", "do", "else", "enum", "extends", "final", "finally", "for", "goto", "if", "implements", "import", "instanceof", "interface", "native", "new", "package", "private", "protected", "public", "return", "static", "strictfp", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "try", "void", "volatile", "while"]
        
        let types = ["boolean", "byte", "char", "double", "float", "int", "long", "short", "String", "Integer", "Boolean", "Double", "Float", "Long", "Short", "Character", "Object"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightKeywords(types, in: &attributedString, color: .blue)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightKotlin(_ attributedString: inout AttributedString) {
        let keywords = ["as", "break", "class", "continue", "do", "else", "for", "fun", "if", "in", "interface", "is", "object", "package", "return", "super", "this", "throw", "try", "typealias", "val", "var", "when", "while", "by", "catch", "constructor", "delegate", "dynamic", "field", "file", "finally", "get", "import", "init", "param", "property", "receiver", "set", "setparam", "where", "actual", "abstract", "annotation", "companion", "const", "crossinline", "data", "enum", "expect", "external", "final", "infix", "inline", "inner", "internal", "lateinit", "noinline", "open", "operator", "out", "override", "private", "protected", "public", "reified", "sealed", "suspend", "tailrec", "vararg"]
        
        let types = ["Boolean", "Byte", "Short", "Int", "Long", "Float", "Double", "Char", "String", "Array", "List", "Map", "Set", "Any", "Nothing", "Unit"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightKeywords(types, in: &attributedString, color: .blue)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightCpp(_ attributedString: inout AttributedString) {
        let keywords = ["alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand", "bitor", "bool", "break", "case", "catch", "char", "char16_t", "char32_t", "class", "compl", "const", "constexpr", "const_cast", "continue", "decltype", "default", "delete", "do", "double", "dynamic_cast", "else", "enum", "explicit", "export", "extern", "false", "float", "for", "friend", "goto", "if", "inline", "int", "long", "mutable", "namespace", "new", "noexcept", "not", "not_eq", "nullptr", "operator", "or", "or_eq", "private", "protected", "public", "register", "reinterpret_cast", "return", "short", "signed", "sizeof", "static", "static_assert", "static_cast", "struct", "switch", "template", "this", "thread_local", "throw", "true", "try", "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual", "void", "volatile", "wchar_t", "while", "xor", "xor_eq"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
        highlightPreprocessor(in: &attributedString)
    }
    
    private func highlightC(_ attributedString: inout AttributedString) {
        let keywords = ["auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto", "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while", "_Alignas", "_Alignof", "_Atomic", "_Generic", "_Noreturn", "_Static_assert", "_Thread_local"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
        highlightPreprocessor(in: &attributedString)
    }
    
    private func highlightCSharp(_ attributedString: inout AttributedString) {
        let keywords = ["abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char", "checked", "class", "const", "continue", "decimal", "default", "delegate", "do", "double", "else", "enum", "event", "explicit", "extern", "false", "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit", "in", "int", "interface", "internal", "is", "lock", "long", "namespace", "new", "null", "object", "operator", "out", "override", "params", "private", "protected", "public", "readonly", "ref", "return", "sbyte", "sealed", "short", "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw", "true", "try", "typeof", "uint", "ulong", "unchecked", "unsafe", "ushort", "using", "virtual", "void", "volatile", "while"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightGo(_ attributedString: inout AttributedString) {
        let keywords = ["break", "case", "chan", "const", "continue", "default", "defer", "else", "fallthrough", "for", "func", "go", "goto", "if", "import", "interface", "map", "package", "range", "return", "select", "struct", "switch", "type", "var"]
        
        let types = ["bool", "byte", "complex128", "complex64", "error", "float32", "float64", "int", "int16", "int32", "int64", "int8", "rune", "string", "uint", "uint16", "uint32", "uint64", "uint8", "uintptr"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightKeywords(types, in: &attributedString, color: .blue)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightRust(_ attributedString: inout AttributedString) {
        let keywords = ["as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "self", "Self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while", "async", "await", "dyn", "abstract", "become", "box", "do", "final", "macro", "override", "priv", "typeof", "unsized", "virtual", "yield", "try"]
        
        let types = ["bool", "char", "str", "i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize", "f32", "f64", "String", "Vec", "Option", "Result"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightKeywords(types, in: &attributedString, color: .blue)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightPHP(_ attributedString: inout AttributedString) {
        let keywords = ["abstract", "and", "array", "as", "break", "callable", "case", "catch", "class", "clone", "const", "continue", "declare", "default", "die", "do", "echo", "else", "elseif", "empty", "enddeclare", "endfor", "endforeach", "endif", "endswitch", "endwhile", "eval", "exit", "extends", "final", "finally", "for", "foreach", "function", "global", "goto", "if", "implements", "include", "include_once", "instanceof", "insteadof", "interface", "isset", "list", "namespace", "new", "or", "print", "private", "protected", "public", "require", "require_once", "return", "static", "switch", "throw", "trait", "try", "unset", "use", "var", "while", "xor", "yield"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString)
        highlightNumbers(in: &attributedString)
        highlightPHPVariables(in: &attributedString)
    }
    
    private func highlightRuby(_ attributedString: inout AttributedString) {
        let keywords = ["alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else", "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super", "then", "true", "undef", "unless", "until", "when", "while", "yield"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "#")
        highlightNumbers(in: &attributedString)
        highlightRubySymbols(in: &attributedString)
    }
    
    private func highlightSCSS(_ attributedString: inout AttributedString) {
        highlightCSS(&attributedString)
        highlightSCSSVariables(in: &attributedString)
        highlightSCSSMixins(in: &attributedString)
    }
    
    private func highlightSQL(_ attributedString: inout AttributedString) {
        let keywords = ["SELECT", "FROM", "WHERE", "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "ON", "GROUP", "BY", "ORDER", "HAVING", "LIMIT", "OFFSET", "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE", "TABLE", "DATABASE", "INDEX", "DROP", "ALTER", "ADD", "COLUMN", "PRIMARY", "KEY", "FOREIGN", "REFERENCES", "NOT", "NULL", "UNIQUE", "DEFAULT", "AUTO_INCREMENT", "CONSTRAINT", "CASCADE", "RESTRICT", "AND", "OR", "IN", "EXISTS", "BETWEEN", "LIKE", "IS", "AS", "DISTINCT", "COUNT", "SUM", "AVG", "MAX", "MIN", "UNION", "ALL"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "--")
        highlightNumbers(in: &attributedString)
    }
    
    private func highlightBash(_ attributedString: inout AttributedString) {
        let keywords = ["if", "then", "else", "elif", "fi", "case", "esac", "for", "select", "while", "until", "do", "done", "in", "function", "time", "coproc", "echo", "printf", "read", "cd", "pwd", "ls", "cp", "mv", "rm", "mkdir", "rmdir", "chmod", "chown", "grep", "sed", "awk", "sort", "uniq", "head", "tail", "cat", "less", "more", "find", "locate", "which", "whereis", "export", "source", "alias", "unalias", "history", "exit", "return", "break", "continue", "test", "true", "false"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "#")
        highlightBashVariables(in: &attributedString)
    }
    
    private func highlightPowerShell(_ attributedString: inout AttributedString) {
        let keywords = ["begin", "break", "catch", "class", "continue", "data", "define", "do", "dynamicparam", "else", "elseif", "end", "exit", "filter", "finally", "for", "foreach", "from", "function", "if", "in", "param", "process", "return", "switch", "throw", "trap", "try", "until", "using", "var", "while", "workflow", "parallel", "sequence", "inlinescript"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "#")
        highlightPowerShellVariables(in: &attributedString)
        highlightPowerShellCmdlets(in: &attributedString)
    }
    
    private func highlightYAML(_ attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        
        // Highlight keys
        let keyPattern = "^\\s*[a-zA-Z_][a-zA-Z0-9_-]*(?=\\s*:)"
        if let regex = try? NSRegularExpression(pattern: keyPattern, options: [.anchorsMatchLines]) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .blue
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                }
            }
        }
        
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "#")
        highlightNumbers(in: &attributedString)
        highlightKeywords(["true", "false", "null", "yes", "no"], in: &attributedString, color: .orange)
    }
    
    private func highlightTOML(_ attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        
        // Highlight sections
        let sectionPattern = "\\[[a-zA-Z0-9._-]+\\]"
        if let regex = try? NSRegularExpression(pattern: sectionPattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .purple
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.bold)
                }
            }
        }
        
        // Highlight keys
        let keyPattern = "^\\s*[a-zA-Z_][a-zA-Z0-9_-]*(?=\\s*=)"
        if let regex = try? NSRegularExpression(pattern: keyPattern, options: [.anchorsMatchLines]) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .blue
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                }
            }
        }
        
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "#")
        highlightNumbers(in: &attributedString)
        highlightKeywords(["true", "false"], in: &attributedString, color: .orange)
    }
    
    private func highlightMarkdown(_ attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        
        // Highlight headers
        let headerPattern = "^#{1,6}\\s+.*$"
        if let regex = try? NSRegularExpression(pattern: headerPattern, options: [.anchorsMatchLines]) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .purple
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.bold)
                }
            }
        }
        
        // Highlight code blocks
        let codeBlockPattern = "```[\\s\\S]*?```"
        if let regex = try? NSRegularExpression(pattern: codeBlockPattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .green
                    attributedString[attributedRange].backgroundColor = Color.secondary.opacity(0.1)
                }
            }
        }
        
        // Highlight inline code
        let inlineCodePattern = "`[^`]+`"
        if let regex = try? NSRegularExpression(pattern: inlineCodePattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .green
                    attributedString[attributedRange].backgroundColor = Color.secondary.opacity(0.1)
                }
            }
        }
        
        // Highlight links
        let linkPattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .blue
                }
            }
        }
        
        // Highlight bold text
        let boldPattern = "\\*\\*([^*]+)\\*\\*"
        if let regex = try? NSRegularExpression(pattern: boldPattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.bold)
                }
            }
        }
    }
    
    private func highlightDockerfile(_ attributedString: inout AttributedString) {
        let keywords = ["FROM", "RUN", "CMD", "LABEL", "MAINTAINER", "EXPOSE", "ENV", "ADD", "COPY", "ENTRYPOINT", "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD", "STOPSIGNAL", "HEALTHCHECK", "SHELL"]
        
        highlightKeywords(keywords, in: &attributedString, color: .purple)
        highlightStrings(in: &attributedString)
        highlightComments(in: &attributedString, commentPrefix: "#")
    }
    
    // MARK: - Helper Highlighting Methods
    
    private func highlightPreprocessor(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "#[a-zA-Z_][a-zA-Z0-9_]*"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .orange
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                }
            }
        }
    }
    
    private func highlightPHPVariables(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .cyan
                }
            }
        }
    }
    
    private func highlightRubySymbols(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = ":[a-zA-Z_][a-zA-Z0-9_]*"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .orange
                }
            }
        }
    }
    
    private func highlightSCSSVariables(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "\\$[a-zA-Z_][a-zA-Z0-9_-]*"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .cyan
                }
            }
        }
    }
    
    private func highlightSCSSMixins(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let patterns = ["@mixin\\s+[a-zA-Z_][a-zA-Z0-9_-]*", "@include\\s+[a-zA-Z_][a-zA-Z0-9_-]*"]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
                
                for match in matches.reversed() {
                    if let range = Range(match.range, in: content) {
                        let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                        attributedString[attributedRange].foregroundColor = .purple
                        attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                    }
                }
            }
        }
    }
    
    private func highlightBashVariables(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let patterns = ["\\$[a-zA-Z_][a-zA-Z0-9_]*", "\\$\\{[a-zA-Z_][a-zA-Z0-9_]*\\}"]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
                
                for match in matches.reversed() {
                    if let range = Range(match.range, in: content) {
                        let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                        attributedString[attributedRange].foregroundColor = .cyan
                    }
                }
            }
        }
    }
    
    private func highlightPowerShellVariables(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "\\$[a-zA-Z_][a-zA-Z0-9_]*"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .cyan
                }
            }
        }
    }
    
    private func highlightPowerShellCmdlets(in attributedString: inout AttributedString) {
        let content = String(attributedString.characters)
        let pattern = "[A-Z][a-z]+-[A-Z][a-zA-Z]*"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: content) {
                    let attributedRange = AttributedString.Index(range.lowerBound, within: attributedString)!..<AttributedString.Index(range.upperBound, within: attributedString)!
                    attributedString[attributedRange].foregroundColor = .blue
                    attributedString[attributedRange].font = .system(.body, design: .monospaced).weight(.semibold)
                }
            }
        }
    }
}
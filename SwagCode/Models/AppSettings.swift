//
//  AppSettings.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @Published var maxClipboardItems: Int = 50
    @Published var autoDetectLanguage: Bool = true
    @Published var showNotifications: Bool = true
    @Published var showClipboardNotifications: Bool = true
    @Published var hotkeysEnabled: Bool = true
    @Published var hotkeyModifiers: HotkeyModifiers = .defaultModifiers
    @Published var startMonitoringOnLaunch: Bool = true
    @Published var syntaxTheme: SyntaxTheme = .system
    @Published var fontSize: Double = 14
    @Published var showLineNumbers: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        print("🔧 AppSettings init called")
        loadSettings()
        print("🔧 AppSettings init completed")
        print("   Final hotkey modifiers: command=\(hotkeyModifiers.command), option=\(hotkeyModifiers.option), control=\(hotkeyModifiers.control), shift=\(hotkeyModifiers.shift)")
        print("   Display string: \(hotkeyModifiers.displayString)")
    }
    
    func loadSettings() {
        print("📖 loadSettings called")
        
        maxClipboardItems = userDefaults.integer(forKey: "maxClipboardItems") == 0 ? 50 : userDefaults.integer(forKey: "maxClipboardItems")
        autoDetectLanguage = userDefaults.object(forKey: "autoDetectLanguage") as? Bool ?? true
        showNotifications = userDefaults.object(forKey: "showNotifications") as? Bool ?? true
        showClipboardNotifications = userDefaults.object(forKey: "showClipboardNotifications") as? Bool ?? true
        hotkeysEnabled = userDefaults.object(forKey: "hotkeysEnabled") as? Bool ?? true
        startMonitoringOnLaunch = userDefaults.object(forKey: "startMonitoringOnLaunch") as? Bool ?? true
        fontSize = userDefaults.object(forKey: "fontSize") as? Double ?? 14
        showLineNumbers = userDefaults.object(forKey: "showLineNumbers") as? Bool ?? false
        hasCompletedOnboarding = userDefaults.object(forKey: "hasCompletedOnboarding") as? Bool ?? false
        
        print("📖 Basic settings loaded, hotkeysEnabled: \(hotkeysEnabled)")
        
        // Force reset hotkey modifiers to new default (⌃⌥) if old settings exist
        if let modifiersData = userDefaults.data(forKey: "hotkeyModifiers"),
           let modifiers = try? JSONDecoder().decode(HotkeyModifiers.self, from: modifiersData) {
            print("📖 Found saved hotkey modifiers: command=\(modifiers.command), option=\(modifiers.option), control=\(modifiers.control), shift=\(modifiers.shift)")
            
            // Check if it's the old default (⌘⇧) and reset to new default (⌃⌥)
            if modifiers.command && modifiers.shift && !modifiers.control && !modifiers.option {
                print("🔄 Migrating from old hotkey settings (⌘⇧) to new ones (⌃⌥)")
                hotkeyModifiers = .defaultModifiers
                saveSettings() // Save the new default immediately
            } else {
                hotkeyModifiers = modifiers
            }
        } else {
            print("📖 No saved hotkey modifiers found, using defaults")
            // No saved modifiers, use new default
            hotkeyModifiers = .defaultModifiers
        }
        
        print("📖 Final hotkey modifiers: command=\(hotkeyModifiers.command), option=\(hotkeyModifiers.option), control=\(hotkeyModifiers.control), shift=\(hotkeyModifiers.shift)")
        
        if let themeRawValue = userDefaults.string(forKey: "syntaxTheme"),
           let theme = SyntaxTheme(rawValue: themeRawValue) {
            syntaxTheme = theme
        }
    }
    
    func saveSettings() {
        userDefaults.set(maxClipboardItems, forKey: "maxClipboardItems")
        userDefaults.set(autoDetectLanguage, forKey: "autoDetectLanguage")
        userDefaults.set(showNotifications, forKey: "showNotifications")
        userDefaults.set(showClipboardNotifications, forKey: "showClipboardNotifications")
        userDefaults.set(hotkeysEnabled, forKey: "hotkeysEnabled")
        userDefaults.set(startMonitoringOnLaunch, forKey: "startMonitoringOnLaunch")
        userDefaults.set(fontSize, forKey: "fontSize")
        userDefaults.set(showLineNumbers, forKey: "showLineNumbers")
        userDefaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        userDefaults.set(syntaxTheme.rawValue, forKey: "syntaxTheme")
        
        if let modifiersData = try? JSONEncoder().encode(hotkeyModifiers) {
            userDefaults.set(modifiersData, forKey: "hotkeyModifiers")
        }
    }
}

struct HotkeyModifiers: Codable {
    var command: Bool
    var option: Bool
    var control: Bool
    var shift: Bool
    
    static let defaultModifiers = HotkeyModifiers(command: false, option: true, control: true, shift: false)
    
    var displayString: String {
        var components: [String] = []
        if command { components.append("⌘") }
        if option { components.append("⌥") }
        if control { components.append("⌃") }
        if shift { components.append("⇧") }
        return components.joined()
    }
}

enum SyntaxTheme: String, Codable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    case vibrant = "vibrant"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .vibrant: return "Vibrant"
        }
    }
}
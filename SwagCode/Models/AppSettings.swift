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
    @Published var hotkeysEnabled: Bool = true
    @Published var hotkeyModifiers: HotkeyModifiers = .defaultModifiers
    @Published var startMonitoringOnLaunch: Bool = true
    @Published var syntaxTheme: SyntaxTheme = .system
    @Published var fontSize: Double = 14
    @Published var showLineNumbers: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        maxClipboardItems = userDefaults.integer(forKey: "maxClipboardItems") == 0 ? 50 : userDefaults.integer(forKey: "maxClipboardItems")
        autoDetectLanguage = userDefaults.object(forKey: "autoDetectLanguage") as? Bool ?? true
        showNotifications = userDefaults.object(forKey: "showNotifications") as? Bool ?? true
        hotkeysEnabled = userDefaults.object(forKey: "hotkeysEnabled") as? Bool ?? true
        startMonitoringOnLaunch = userDefaults.object(forKey: "startMonitoringOnLaunch") as? Bool ?? true
        fontSize = userDefaults.object(forKey: "fontSize") as? Double ?? 14
        showLineNumbers = userDefaults.object(forKey: "showLineNumbers") as? Bool ?? false
        hasCompletedOnboarding = userDefaults.object(forKey: "hasCompletedOnboarding") as? Bool ?? false
        
        if let modifiersData = userDefaults.data(forKey: "hotkeyModifiers"),
           let modifiers = try? JSONDecoder().decode(HotkeyModifiers.self, from: modifiersData) {
            hotkeyModifiers = modifiers
        }
        
        if let themeRawValue = userDefaults.string(forKey: "syntaxTheme"),
           let theme = SyntaxTheme(rawValue: themeRawValue) {
            syntaxTheme = theme
        }
    }
    
    func saveSettings() {
        userDefaults.set(maxClipboardItems, forKey: "maxClipboardItems")
        userDefaults.set(autoDetectLanguage, forKey: "autoDetectLanguage")
        userDefaults.set(showNotifications, forKey: "showNotifications")
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
    
    static let defaultModifiers = HotkeyModifiers(command: true, option: true, control: false, shift: false)
    
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
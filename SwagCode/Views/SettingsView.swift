//
//  SettingsView.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var clipboardManager: ClipboardManager
    @ObservedObject var hotkeyManager: HotkeyManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case hotkeys = "Hotkeys"
        case appearance = "Appearance"
        case data = "Data"
        case about = "About"
        
        var icon: String {
            switch self {
            case .general: return "gear"
            case .hotkeys: return "keyboard"
            case .appearance: return "paintbrush"
            case .data: return "folder"
            case .about: return "info.circle"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "gear")
                        .font(.system(size: 32))
                        .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Tabs
                VStack(spacing: 4) {
                    ForEach(SettingsTab.allCases, id: \.self) { tab in
                        SettingsTabButton(
                            tab: tab,
                            isSelected: selectedTab == tab
                        ) {
                            selectedTab = tab
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                Spacer()
                
                // Close button
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: 200)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        } detail: {
            // Main content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Tab content
                    Group {
                        switch selectedTab {
                        case .general:
                            generalSettings
                        case .hotkeys:
                            hotkeySettings
                        case .appearance:
                            appearanceSettings
                        case .data:
                            dataSettings
                        case .about:
                            aboutSettings
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(NSColor.textBackgroundColor))
        }
        .navigationSplitViewStyle(.balanced)
        .frame(width: 700, height: 500)
        .onDisappear {
            settings.saveSettings()
        }
    }
    
    // MARK: - Settings Sections
    
    @ViewBuilder
    private var generalSettings: some View {
        settingsSection("General Settings", icon: "gear") {
            VStack(spacing: 16) {
                SettingsRow(
                    title: "Maximum clipboard items",
                    description: "Number of items to keep in clipboard history"
                ) {
                    HStack {
                        Stepper(
                            value: $settings.maxClipboardItems,
                            in: 10...500,
                            step: 10
                        ) {
                            Text("\(settings.maxClipboardItems)")
                                .frame(minWidth: 50)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.medium)
                        }
                    }
                }
                
                SettingsRow(
                    title: "Auto-detect programming language",
                    description: "Automatically detect the programming language of copied code"
                ) {
                    Toggle("", isOn: $settings.autoDetectLanguage)
                        .toggleStyle(.switch)
                }
                
                SettingsRow(
                    title: "Show hotkey notifications",
                    description: "Display notifications when using hotkeys to paste items"
                ) {
                    Toggle("", isOn: $settings.showNotifications)
                        .toggleStyle(.switch)
                }
                
                SettingsRow(
                    title: "Show clipboard notifications",
                    description: "Display notifications when new items are detected and saved"
                ) {
                    Toggle("", isOn: $settings.showClipboardNotifications)
                        .toggleStyle(.switch)
                }
                
                SettingsRow(
                    title: "Start monitoring on launch",
                    description: "Automatically start clipboard monitoring when app launches"
                ) {
                    Toggle("", isOn: $settings.startMonitoringOnLaunch)
                        .toggleStyle(.switch)
                }
            }
        }
    }
    
    @ViewBuilder
    private var hotkeySettings: some View {
        settingsSection("Hotkey Settings", icon: "keyboard") {
            VStack(spacing: 20) {
                SettingsRow(
                    title: "Enable global hotkeys",
                    description: "Allow using keyboard shortcuts to paste clipboard items system-wide"
                ) {
                    Toggle("", isOn: $settings.hotkeysEnabled)
                        .toggleStyle(.switch)
                        .onChange(of: settings.hotkeysEnabled) { _ in
                            hotkeyManager.updateHotkeys()
                        }
                }
                
                if settings.hotkeysEnabled {
                    VStack(spacing: 16) {
                        Text("Hotkey Modifiers")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            HotkeyModifierRow(
                                symbol: "⌘",
                                name: "Command",
                                isEnabled: $settings.hotkeyModifiers.command
                            ) {
                                hotkeyManager.updateHotkeys()
                            }
                            
                            HotkeyModifierRow(
                                symbol: "⌥",
                                name: "Option",
                                isEnabled: $settings.hotkeyModifiers.option
                            ) {
                                hotkeyManager.updateHotkeys()
                            }
                            
                            HotkeyModifierRow(
                                symbol: "⌃",
                                name: "Control",
                                isEnabled: $settings.hotkeyModifiers.control
                            ) {
                                hotkeyManager.updateHotkeys()
                            }
                            
                            HotkeyModifierRow(
                                symbol: "⇧",
                                name: "Shift",
                                isEnabled: $settings.hotkeyModifiers.shift
                            ) {
                                hotkeyManager.updateHotkeys()
                            }
                        }
                        
                        // Preview
                        VStack(spacing: 8) {
                            Text("Current Hotkeys")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text("\(settings.hotkeyModifiers.displayString) + 1-9")
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.leading, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
    }
    
    @ViewBuilder
    private var appearanceSettings: some View {
        settingsSection("Appearance Settings", icon: "paintbrush") {
            VStack(spacing: 16) {
                SettingsRow(
                    title: "Syntax highlighting theme",
                    description: "Choose the color scheme for syntax highlighting"
                ) {
                    Picker("Theme", selection: $settings.syntaxTheme) {
                        ForEach(SyntaxTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(minWidth: 120)
                }
                
                SettingsRow(
                    title: "Font size",
                    description: "Size of the monospace font used for code display"
                ) {
                    HStack {
                        Stepper(
                            value: $settings.fontSize,
                            in: 10...24,
                            step: 1
                        ) {
                            Text("\(settings.fontSize, specifier: "%.0f") pt")
                                .frame(minWidth: 50)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                
                SettingsRow(
                    title: "Show line numbers",
                    description: "Display line numbers in code snippets"
                ) {
                    Toggle("", isOn: $settings.showLineNumbers)
                        .toggleStyle(.switch)
                }
            }
        }
    }
    
    @ViewBuilder
    private var dataSettings: some View {
        settingsSection("Data Management", icon: "folder") {
            VStack(spacing: 16) {
                SettingsRow(
                    title: "Total clipboard items",
                    description: "Number of items currently stored"
                ) {
                    Text("\(clipboardManager.clipboardItems.count)")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                SettingsRow(
                    title: "Monitoring status",
                    description: "Current state of clipboard monitoring"
                ) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(clipboardManager.isMonitoring ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(clipboardManager.isMonitoring ? "Active" : "Inactive")
                            .fontWeight(.medium)
                            .foregroundColor(clipboardManager.isMonitoring ? .green : .red)
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                VStack(spacing: 12) {
                    Button(action: {
                        clipboardManager.clearAll()
                    }) {
                        Label("Clear All Items", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .foregroundColor(.red)
                    
                    Button(action: exportData) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button(action: importData) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
    }
    
    @ViewBuilder
    private var aboutSettings: some View {
        settingsSection("About SwagCode", icon: "info.circle") {
            VStack(spacing: 20) {
                // App icon and info
                VStack(spacing: 16) {
                    Image(systemName: "doc.on.clipboard.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    VStack(spacing: 8) {
                        Text("SwagCode")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("A powerful clipboard manager for developers")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Features
                VStack(spacing: 12) {
                    Text("Features")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        SettingsFeatureRow(icon: "doc.on.clipboard", text: "Clipboard history management")
                        SettingsFeatureRow(icon: "keyboard", text: "Global hotkey support")
                        SettingsFeatureRow(icon: "curlybraces", text: "Syntax highlighting for 25+ languages")
                        SettingsFeatureRow(icon: "magnifyingglass", text: "Smart search and filtering")
                        SettingsFeatureRow(icon: "square.and.arrow.up", text: "Easy sharing capabilities")
                        SettingsFeatureRow(icon: "gear", text: "Customizable settings")
                    }
                }
                
                Divider()
                
                // System info
                VStack(spacing: 8) {
                    Text("System Information")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("macOS \(ProcessInfo.processInfo.operatingSystemVersionString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("SwiftUI • No third-party dependencies")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func settingsSection<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            content()
        }
    }
    
    // MARK: - Helper Methods
    
    private func exportData() {
        // Implementation for exporting clipboard data
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "SwagCode-Export-\(DateFormatter().string(from: Date()))"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Export logic here
                print("Export to: \(url)")
            }
        }
    }
    
    private func importData() {
        // Implementation for importing clipboard data
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.urls.first {
                // Import logic here
                print("Import from: \(url)")
            }
        }
    }
}

// MARK: - Supporting Views

struct SettingsTabButton: View {
    let tab: SettingsView.SettingsTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(width: 20)
                
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let description: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 8)
    }
}

struct HotkeyModifierRow: View {
    let symbol: String
    let name: String
    @Binding var isEnabled: Bool
    let onChange: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(symbol)
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 24)
                
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .toggleStyle(.switch)
                .onChange(of: isEnabled) { _ in
                    onChange()
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct SettingsFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView(
        settings: AppSettings(),
        clipboardManager: ClipboardManager(settings: AppSettings()),
        hotkeyManager: HotkeyManager(clipboardManager: ClipboardManager(settings: AppSettings()), settings: AppSettings())
    )
}
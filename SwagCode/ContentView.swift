//
//  ContentView.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var clipboardManager: ClipboardManager
    @EnvironmentObject var hotkeyManager: HotkeyManager
    
    @State private var searchText = ""
    @State private var selectedLanguageFilter: ProgrammingLanguage? = nil
    @State private var selectedTypeFilter: ClipboardItemType? = nil
    @State private var showingSettings = false
    @State private var selectedItem: ClipboardItem? = nil
    
    var filteredItems: [ClipboardItem] {
        var items = clipboardManager.clipboardItems
        
        // Search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.content.localizedCaseInsensitiveContains(searchText) ||
                item.displayTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Language filter
        if let languageFilter = selectedLanguageFilter {
            items = items.filter { $0.language == languageFilter }
        }
        
        // Type filter
        if let typeFilter = selectedTypeFilter {
            items = items.filter { $0.type == typeFilter }
        }
        
        return items
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Search
                searchSection
                
                // Filters
                filtersSection
                
                // Stats
                statsSection
                
                Spacer()
                
                // Quick actions
                quickActionsSection
            }
            .padding(20)
            .frame(minWidth: 280, maxWidth: 320)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        } detail: {
            // Main content
            mainContentSection
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                settings: settings,
                clipboardManager: clipboardManager,
                hotkeyManager: hotkeyManager
            )
        }
        .onAppear {
            // Request notification permissions asynchronously to avoid blocking UI
            DispatchQueue.global(qos: .utility).async {
                self.requestNotificationPermissions()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "doc.on.clipboard.fill")
                        .font(.title2)
                        .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("SwagCode")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Text("Clipboard Manager for Developers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
            .help("Settings")
        }
    }
    
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                
                TextField("Search snippets...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Type filter
            filterGroup(title: "Type") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedTypeFilter == nil
                        ) {
                            selectedTypeFilter = nil
                        }
                        
                        ForEach(ClipboardItemType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.rawValue.capitalized,
                                icon: type.icon,
                                color: type.color,
                                isSelected: selectedTypeFilter == type
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTypeFilter = selectedTypeFilter == type ? nil : type
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Language filter
            filterGroup(title: "Language") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedLanguageFilter == nil
                        ) {
                            selectedLanguageFilter = nil
                        }
                        
                        ForEach(ProgrammingLanguage.allCases.filter { lang in
                            clipboardManager.clipboardItems.contains { $0.language == lang }
                        }, id: \.self) { language in
                            FilterChip(
                                title: language.displayName,
                                color: language.color,
                                isSelected: selectedLanguageFilter == language
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedLanguageFilter = selectedLanguageFilter == language ? nil : language
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private func filterGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            content()
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                StatRow(
                    icon: "doc.on.clipboard",
                    title: "Total items",
                    value: "\(clipboardManager.clipboardItems.count)"
                )
                
                StatRow(
                    icon: "line.3.horizontal.decrease.circle",
                    title: "Filtered items",
                    value: "\(filteredItems.count)"
                )
                
                StatRow(
                    icon: clipboardManager.isMonitoring ? "eye" : "eye.slash",
                    title: "Monitoring",
                    value: clipboardManager.isMonitoring ? "Active" : "Inactive",
                    valueColor: clipboardManager.isMonitoring ? .green : .red
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                if clipboardManager.isMonitoring {
                    clipboardManager.stopMonitoring()
                } else {
                    clipboardManager.startMonitoring()
                }
            }) {
                Label(
                    clipboardManager.isMonitoring ? "Pause Monitoring" : "Start Monitoring",
                    systemImage: clipboardManager.isMonitoring ? "pause.circle" : "play.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Button(action: {
                withAnimation {
                    clipboardManager.clearAll()
                }
            }) {
                Label("Clear All Items", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .foregroundColor(.red)
        }
    }
    
    private var mainContentSection: some View {
        VStack(spacing: 0) {
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                itemsListView
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 80))
                .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .opacity(0.6)
            
            VStack(spacing: 8) {
                Text(clipboardManager.clipboardItems.isEmpty ? "No clipboard items yet" : "No items match your filters")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(clipboardManager.clipboardItems.isEmpty ? 
                     "Copy some text or code to get started.\nUse ⌘⌥1-9 hotkeys to quickly paste saved items." : 
                     "Try adjusting your search or filters to find what you're looking for.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .font(.body)
            }
            
            if clipboardManager.clipboardItems.isEmpty {
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        HotkeyIndicator(keys: "⌘⌥1", description: "Paste latest")
                        HotkeyIndicator(keys: "⌘⌥2", description: "Paste 2nd latest")
                        HotkeyIndicator(keys: "⌘⌥3", description: "Paste 3rd latest")
                    }
                    
                    Text("...and so on up to ⌘⌥9")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    ClipboardItemRow(
                        item: item,
                        index: clipboardManager.clipboardItems.firstIndex(of: item) ?? index,
                        clipboardManager: clipboardManager
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .padding(20)
        }
        .animation(.easeInOut(duration: 0.3), value: filteredItems.map(\.id))
    }
    
    // MARK: - Helper Methods
    
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let valueColor: Color?
    
    init(icon: String, title: String, value: String, valueColor: Color? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.caption)
                .frame(width: 16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(valueColor ?? .primary)
        }
    }
}

struct HotkeyIndicator: View {
    let keys: String
    let description: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(keys)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String?
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, color: Color = .accentColor, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color(NSColor.controlBackgroundColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
        .environmentObject(ClipboardManager(settings: AppSettings()))
        .environmentObject(HotkeyManager(clipboardManager: ClipboardManager(settings: AppSettings()), settings: AppSettings()))
        .frame(width: 1200, height: 800)
}

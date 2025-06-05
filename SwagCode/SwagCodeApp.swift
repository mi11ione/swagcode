//
//  SwagCodeApp.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import SwiftUI

@main
struct SwagCodeApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var clipboardManager: ClipboardManager
    @StateObject private var hotkeyManager: HotkeyManager
    @State private var statusBarController: StatusBarController?
    @State private var showingOnboarding = false
    
    init() {
        // Create single instance of settings to avoid conflicts
        let sharedSettings = AppSettings()
        let clipboardManager = ClipboardManager(settings: sharedSettings)
        let hotkeyManager = HotkeyManager(clipboardManager: clipboardManager, settings: sharedSettings)
        
        self._settings = StateObject(wrappedValue: sharedSettings)
        self._clipboardManager = StateObject(wrappedValue: clipboardManager)
        self._hotkeyManager = StateObject(wrappedValue: hotkeyManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(clipboardManager)
                .environmentObject(hotkeyManager)
                .onAppear {
                    // Setup everything asynchronously to avoid blocking UI
                    DispatchQueue.main.async {
                        self.setupStatusBar()
                        
                        // Check if onboarding is needed
                        if !self.settings.hasCompletedOnboarding {
                            self.showingOnboarding = true
                        } else {
                            self.startAppIfNeeded()
                        }
                    }
                }
                .sheet(isPresented: $showingOnboarding) {
                    OnboardingView(
                        settings: settings, 
                        hotkeyManager: hotkeyManager,
                        clipboardManager: clipboardManager
                    )
                    .frame(width: 720, height: 600)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Preferences...") {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            
            CommandGroup(replacing: .newItem) {
                Button("Show SwagCode") {
                    NSApp.activate(ignoringOtherApps: true)
                    if let window = NSApp.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                .keyboardShortcut("1", modifiers: [.command, .shift])
                
                Button("Clear All Clipboard Items") {
                    clipboardManager.clearAll()
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView(
                settings: settings,
                clipboardManager: clipboardManager,
                hotkeyManager: hotkeyManager
            )
        }
    }
    
    private func setupStatusBar() {
        statusBarController = StatusBarController(
            clipboardManager: clipboardManager,
            settings: settings
        )
    }
    
    private func startAppIfNeeded() {
        // Start monitoring clipboard if enabled
        if settings.startMonitoringOnLaunch {
            clipboardManager.startMonitoring()
        }
        
        // Setup hotkeys if permissions are granted (check asynchronously)
        if settings.hotkeysEnabled {
            DispatchQueue.global(qos: .userInitiated).async {
                let hasPermissions = self.hotkeyManager.checkAccessibilityPermissions()
                if hasPermissions {
                    DispatchQueue.main.async {
                        self.hotkeyManager.updateHotkeys()
                    }
                }
            }
        }
    }
    

}

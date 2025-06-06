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
    @State private var showingSettings = false
    @State private var selectedSettingsTab: SettingsView.SettingsTab = .general
    
    init() {
        // Create single instance of settings to avoid conflicts
        let sharedSettings = AppSettings()
        let clipboardManager = ClipboardManager(settings: sharedSettings)
        let hotkeyManager = HotkeyManager(clipboardManager: clipboardManager, settings: sharedSettings)
        
        self._settings = StateObject(wrappedValue: sharedSettings)
        self._clipboardManager = StateObject(wrappedValue: clipboardManager)
        self._hotkeyManager = StateObject(wrappedValue: hotkeyManager)
        
        // Debug: Print initial settings
        print("🔧 SwagCodeApp init - Initial hotkey settings:")
        print("   command: \(sharedSettings.hotkeyModifiers.command)")
        print("   option: \(sharedSettings.hotkeyModifiers.option)")
        print("   control: \(sharedSettings.hotkeyModifiers.control)")
        print("   shift: \(sharedSettings.hotkeyModifiers.shift)")
        print("   displayString: \(sharedSettings.hotkeyModifiers.displayString)")
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
                .sheet(isPresented: $showingSettings) {
                    SettingsViewWithTab(
                        settings: settings,
                        clipboardManager: clipboardManager,
                        hotkeyManager: hotkeyManager,
                        selectedTab: $selectedSettingsTab
                    )
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
                .keyboardShortcut("1", modifiers: [.control, .option])
                
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
        print("🚀 startAppIfNeeded called")
        
        // Start monitoring clipboard if enabled
        if settings.startMonitoringOnLaunch {
            print("📋 Starting clipboard monitoring")
            clipboardManager.startMonitoring()
        }
        
        // Setup hotkeys if permissions are granted (check asynchronously)
        print("🔑 Setting up hotkeys...")
        DispatchQueue.global(qos: .userInitiated).async {
            let permissions = self.hotkeyManager.checkAllPermissions()
            
            DispatchQueue.main.async {
                print("🔑 Calling hotkeyManager.startHotkeys()")
                self.hotkeyManager.startHotkeys()
                
                // Check if permissions are missing and hotkeys are enabled
                if self.settings.hotkeysEnabled && (!permissions.accessibility || !permissions.inputMonitoring) {
                    print("⚠️ Missing permissions detected, opening settings...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.selectedSettingsTab = .permissions
                        self.showingSettings = true
                    }
                }
            }
        }
    }
    

}

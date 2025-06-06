//
//  HotkeyManager.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import Foundation
import AppKit
import Carbon

class HotkeyManager: ObservableObject {
    private var eventMonitor: Any?
    private weak var clipboardManager: ClipboardManager?
    private let settings: AppSettings
    
    init(clipboardManager: ClipboardManager, settings: AppSettings) {
        self.clipboardManager = clipboardManager
        self.settings = settings
        // Don't setup hotkeys in init to avoid potential deadlocks
        // Will be setup later when permissions are confirmed
    }
    
    deinit {
        removeHotkeys()
    }
    
    func setupHotkeys() {
        print("🔧 setupHotkeys called")
        print("   hotkeysEnabled: \(settings.hotkeysEnabled)")
        print("   Current modifiers: \(settings.hotkeyModifiers.displayString)")
        print("   Raw modifier values: command=\(settings.hotkeyModifiers.command), option=\(settings.hotkeyModifiers.option), control=\(settings.hotkeyModifiers.control), shift=\(settings.hotkeyModifiers.shift)")
        
        guard settings.hotkeysEnabled else { 
            print("   ❌ Hotkeys disabled, removing...")
            removeHotkeys()
            return 
        }
        
        removeHotkeys()
        
        // Create global event monitor for key combinations
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        print("   ✅ Global event monitor created")
    }
    
    private func removeHotkeys() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        guard settings.hotkeysEnabled else { return }
        
        let modifierFlags = event.modifierFlags
        let keyCode = event.keyCode
        
        // Check if it's a number key (1-9) first
        let numberKey = getNumberFromKeyCode(keyCode)
        guard numberKey >= 1 && numberKey <= 9 else { return }
        
        // Build expected modifiers
        var expectedModifiers: NSEvent.ModifierFlags = []
        if settings.hotkeyModifiers.command { expectedModifiers.insert(.command) }
        if settings.hotkeyModifiers.option { expectedModifiers.insert(.option) }
        if settings.hotkeyModifiers.control { expectedModifiers.insert(.control) }
        if settings.hotkeyModifiers.shift { expectedModifiers.insert(.shift) }
        
        // Get only the relevant modifier flags (ignore caps lock, function, etc.)
        let relevantFlags = modifierFlags.intersection([.command, .option, .control, .shift])
        
        // Debug logging
        print("🔥 HotkeyManager Debug:")
        print("   Number key: \(numberKey)")
        print("   Expected modifiers: \(expectedModifiers)")
        print("   Actual modifiers: \(relevantFlags)")
        print("   Settings: command=\(settings.hotkeyModifiers.command), option=\(settings.hotkeyModifiers.option), control=\(settings.hotkeyModifiers.control), shift=\(settings.hotkeyModifiers.shift)")
        
        // Check if modifiers match exactly
        guard relevantFlags == expectedModifiers else { 
            print("   ❌ Modifiers don't match!")
            return 
        }
        
        print("   ✅ Hotkey matched! Handling...")
        
        // Handle the hotkey
        DispatchQueue.main.async {
            self.handleHotkey(number: numberKey)
        }
    }
    
    private func getNumberFromKeyCode(_ keyCode: UInt16) -> Int {
        switch keyCode {
        case 18: return 1  // kVK_ANSI_1
        case 19: return 2  // kVK_ANSI_2
        case 20: return 3  // kVK_ANSI_3
        case 21: return 4  // kVK_ANSI_4
        case 23: return 5  // kVK_ANSI_5
        case 22: return 6  // kVK_ANSI_6
        case 26: return 7  // kVK_ANSI_7
        case 28: return 8  // kVK_ANSI_8
        case 25: return 9  // kVK_ANSI_9
        default: return 0
        }
    }
    
    private func handleHotkey(number: Int) {
        print("🚀 handleHotkey called with number: \(number)")
        
        guard let clipboardManager = self.clipboardManager else { 
            print("❌ No clipboardManager")
            return 
        }
        let index = number - 1
        
        print("📋 Clipboard has \(clipboardManager.clipboardItems.count) items, looking for index \(index)")
        
        guard index >= 0 && index < clipboardManager.clipboardItems.count else { 
            print("❌ Index \(index) out of bounds")
            return 
        }
        
        let item = clipboardManager.clipboardItems[index]
        print("✅ Found item: \(String(item.content.prefix(50)))...")
        
        clipboardManager.copyToClipboard(item)
        print("📋 Item copied to clipboard")
        
        // Show brief notification
        if settings.showNotifications {
            showHotkeyNotification(for: item, number: number)
            print("🔔 Notification shown")
        }
    }
    
    private func showHotkeyNotification(for item: ClipboardItem, number: Int) {
        let notification = NSUserNotification()
        notification.title = "SwagCode"
        notification.subtitle = "Pasted item #\(number)"
        notification.informativeText = String(item.displayTitle.prefix(50))
        notification.soundName = nil // Silent notification
        
        NSUserNotificationCenter.default.deliver(notification)
        
        // Auto-remove after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NSUserNotificationCenter.default.removeDeliveredNotification(notification)
        }
    }
    
    func updateHotkeys() {
        // Remove existing hotkeys first
        removeHotkeys()
        
        // Setup new hotkeys with current settings
        if settings.hotkeysEnabled {
            setupHotkeys()
        }
    }
    
    func startHotkeys() {
        print("🔑 startHotkeys called")
        let permissions = checkAllPermissions()
        
        print("   hotkeysEnabled: \(settings.hotkeysEnabled)")
        print("   accessibility: \(permissions.accessibility)")
        print("   inputMonitoring: \(permissions.inputMonitoring)")
        
        if settings.hotkeysEnabled && permissions.accessibility && permissions.inputMonitoring {
            print("   ✅ All conditions met, calling setupHotkeys()")
            setupHotkeys()
        } else {
            print("   ❌ Conditions not met:")
            if !settings.hotkeysEnabled { print("      - Hotkeys disabled") }
            if !permissions.accessibility { print("      - No accessibility permission") }
            if !permissions.inputMonitoring { print("      - No input monitoring permission") }
        }
    }
    
    // MARK: - Permissions Check
    
    func checkAccessibilityPermissions() -> Bool {
        // First check without prompt
        let hasPermissionInitial = AXIsProcessTrusted()
        print("🔐 Initial accessibility permission check: \(hasPermissionInitial)")
        
        if !hasPermissionInitial {
            print("🔐 No accessibility permission - requesting with prompt...")
            
            // Request permission with prompt - this should show system dialog
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
            let hasPermissionAfterPrompt = AXIsProcessTrustedWithOptions(options as CFDictionary)
            print("🔐 Permission after prompt: \(hasPermissionAfterPrompt)")
            
            // Wait a bit and check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let finalCheck = AXIsProcessTrusted()
                print("🔐 Final permission check: \(finalCheck)")
                
                if finalCheck {
                    print("🎉 Permission granted! Restarting hotkeys...")
                    self.startHotkeys()
                } else {
                    print("🔐 Still no permission - opening settings...")
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                    NSWorkspace.shared.open(url)
                }
            }
            
            return hasPermissionAfterPrompt
        }
        
        return hasPermissionInitial
    }
    
    func checkInputMonitoringPermissions() -> Bool {
        // Check if we have input monitoring permissions
        // This is needed for global key event monitoring
        if #available(macOS 10.15, *) {
            // Try to create a temporary monitor to test permissions
            var hasPermission = false
            let testMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { _ in
                // This block won't be called if we don't have permission
            }
            
            if testMonitor != nil {
                hasPermission = true
                NSEvent.removeMonitor(testMonitor!)
            }
            
            print("🔐 Input monitoring permission check: \(hasPermission)")
            return hasPermission
        }
        print("🔐 Input monitoring permission check: true (macOS < 10.15)")
        return true // Older macOS versions don't require explicit permission
    }
    
    func checkAllPermissions() -> (accessibility: Bool, inputMonitoring: Bool) {
        return (
            accessibility: checkAccessibilityPermissions(),
            inputMonitoring: checkInputMonitoringPermissions()
        )
    }
    
    func requestAccessibilityPermissions() {
        // This method is now handled by the onboarding flow
        // We just open system preferences without blocking
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
    
    func requestInputMonitoringPermissions() {
        // Open Input Monitoring preferences
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
    }
    
    // Force recheck permissions and restart hotkeys if needed
    func recheckPermissions() {
        print("🔄 Force rechecking permissions...")
        let permissions = checkAllPermissions()
        
        if permissions.accessibility && permissions.inputMonitoring && settings.hotkeysEnabled {
            print("🎉 All permissions granted! Setting up hotkeys...")
            setupHotkeys()
        } else {
            print("❌ Still missing permissions:")
            if !permissions.accessibility { print("   - Accessibility") }
            if !permissions.inputMonitoring { print("   - Input Monitoring") }
        }
    }
}
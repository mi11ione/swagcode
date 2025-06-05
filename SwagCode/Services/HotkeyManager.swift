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
        guard settings.hotkeysEnabled else { 
            removeHotkeys()
            return 
        }
        
        removeHotkeys()
        
        // Create global event monitor for key combinations
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
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
        
        // Check if the modifier keys match our settings
        let hasCommand = modifierFlags.contains(.command) == settings.hotkeyModifiers.command
        let hasOption = modifierFlags.contains(.option) == settings.hotkeyModifiers.option
        let hasControl = modifierFlags.contains(.control) == settings.hotkeyModifiers.control
        let hasShift = modifierFlags.contains(.shift) == settings.hotkeyModifiers.shift
        
        // Ensure we don't have extra modifiers
        let expectedModifiers: NSEvent.ModifierFlags = [
            settings.hotkeyModifiers.command ? .command : [],
            settings.hotkeyModifiers.option ? .option : [],
            settings.hotkeyModifiers.control ? .control : [],
            settings.hotkeyModifiers.shift ? .shift : []
        ].reduce([], { $0.union($1) })
        
        let relevantFlags = modifierFlags.intersection([.command, .option, .control, .shift])
        
        guard relevantFlags == expectedModifiers else { return }
        
        // Check if it's a number key (1-9)
        let numberKey = getNumberFromKeyCode(keyCode)
        guard numberKey >= 1 && numberKey <= 9 else { return }
        
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
        guard let clipboardManager = self.clipboardManager else { return }
        let index = number - 1
        
        guard index >= 0 && index < clipboardManager.clipboardItems.count else { return }
        
        let item = clipboardManager.clipboardItems[index]
        clipboardManager.copyToClipboard(item)
        
        // Show brief notification
        if settings.showNotifications {
            showHotkeyNotification(for: item, number: number)
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
        setupHotkeys()
    }
    
    // MARK: - Accessibility Check
    
    func checkAccessibilityPermissions() -> Bool {
        // Check without showing system prompt to avoid blocking UI
        return AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermissions() {
        // This method is now handled by the onboarding flow
        // We just open system preferences without blocking
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
}
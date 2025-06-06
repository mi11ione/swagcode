//
//  ClipboardManager.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import Foundation
import AppKit
import SwiftUI
import CoreGraphics
import UserNotifications

class ClipboardManager: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    @Published var isMonitoring: Bool = false
    
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pasteboard = NSPasteboard.general
    private let settings: AppSettings
    
    init(settings: AppSettings) {
        self.settings = settings
        loadClipboardItems()
        
        // Don't start monitoring automatically in init to avoid deadlocks
        // Will be started manually after app setup is complete
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        lastChangeCount = pasteboard.changeCount
        
        // Check if current clipboard content is already in our list
        if let currentString = pasteboard.string(forType: .string),
           !currentString.isEmpty,
           let firstItem = clipboardItems.first,
           firstItem.content != currentString {
            // Current clipboard content is different from our latest saved item
            // This means something was copied while app was closed, so add it
            checkClipboard()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        let currentChangeCount = pasteboard.changeCount
        
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount
        
        guard let string = pasteboard.string(forType: .string),
              !string.isEmpty,
              !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Don't add duplicate items
        if let lastItem = clipboardItems.first, lastItem.content == string {
            return
        }
        
        let itemType = detectItemType(string)
        let language = settings.autoDetectLanguage ? ProgrammingLanguage.detectLanguage(from: string) : .plain
        
        let newItem = ClipboardItem(
            content: string,
            timestamp: Date(),
            type: itemType,
            language: language
        )
        
        DispatchQueue.main.async {
            self.clipboardItems.insert(newItem, at: 0)
            
            // Limit the number of items
            if self.clipboardItems.count > self.settings.maxClipboardItems {
                self.clipboardItems = Array(self.clipboardItems.prefix(self.settings.maxClipboardItems))
            }
            
            self.saveClipboardItems()
            
            if self.settings.showClipboardNotifications {
                self.showClipboardNotification(for: newItem)
            }
        }
    }
    
    private func detectItemType(_ content: String) -> ClipboardItemType {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // URL detection
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") || trimmed.hasPrefix("www.") {
            return .url
        }
        
        // Email detection
        if trimmed.contains("@") && trimmed.contains(".") && !trimmed.contains(" ") {
            return .email
        }
        
        // Code detection (basic heuristics)
        let codeIndicators = ["{", "}", "(", ")", "[", "]", "function", "class", "import", "def ", "var ", "let ", "const "]
        let hasCodeIndicators = codeIndicators.contains { trimmed.contains($0) }
        
        if hasCodeIndicators || trimmed.components(separatedBy: .newlines).count > 3 {
            return .code
        }
        
        return .text
    }
    
    private func showClipboardNotification(for item: ClipboardItem) {
        let content = UNMutableNotificationContent()
        content.title = "SwagCode"
        content.subtitle = "New \(item.type.rawValue) saved"
        content.body = String(item.displayTitle.prefix(100))
        content.sound = nil // Silent notification to avoid annoyance
        
        let request = UNNotificationRequest(
            identifier: "clipboard-\(item.id)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔔 Clipboard notification error: \(error)")
            } else {
                print("🔔 Clipboard notification sent successfully")
            }
        }
    }
    
    func copyToClipboard(_ item: ClipboardItem) {
        // Copy to system clipboard
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        lastChangeCount = pasteboard.changeCount // Prevent re-adding the same item
        print("📋 ClipboardManager: Item copied to system clipboard")
    }
    

    
    func deleteItem(_ item: ClipboardItem) {
        clipboardItems.removeAll { $0.id == item.id }
        saveClipboardItems()
    }
    
    func clearAll() {
        clipboardItems.removeAll()
        saveClipboardItems()
    }
    
    func shareItem(_ item: ClipboardItem) {
        let sharingService = NSSharingService(named: .composeMessage)
        sharingService?.perform(withItems: [item.content])
    }
    
    // MARK: - Persistence
    
    private func saveClipboardItems() {
        do {
            let data = try JSONEncoder().encode(clipboardItems)
            UserDefaults.standard.set(data, forKey: "clipboardItems")
        } catch {
            print("Failed to save clipboard items: \(error)")
        }
    }
    
    private func loadClipboardItems() {
        guard let data = UserDefaults.standard.data(forKey: "clipboardItems") else { return }
        
        do {
            clipboardItems = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("Failed to load clipboard items: \(error)")
        }
    }
}
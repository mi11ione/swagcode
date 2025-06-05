//
//  ClipboardManager.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import Foundation
import AppKit
import SwiftUI

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
            
            if self.settings.showNotifications {
                self.showNotification(for: newItem)
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
    
    private func showNotification(for item: ClipboardItem) {
        let notification = NSUserNotification()
        notification.title = "SwagCode"
        notification.subtitle = "New \(item.type.rawValue) saved"
        notification.informativeText = String(item.displayTitle.prefix(100))
        notification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func copyToClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        lastChangeCount = pasteboard.changeCount // Prevent re-adding the same item
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
//
//  StatusBarController.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import AppKit
import SwiftUI

class StatusBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private let clipboardManager: ClipboardManager
    private let settings: AppSettings
    
    init(clipboardManager: ClipboardManager, settings: AppSettings) {
        self.clipboardManager = clipboardManager
        self.settings = settings
        setupStatusBar()
    }
    
    deinit {
        statusItem = nil
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard.fill", accessibilityDescription: "SwagCode")
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        updateStatusItemMenu()
    }
    
    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            showQuickAccessMenu()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Show SwagCode", action: #selector(showMainWindow), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit SwagCode", action: #selector(quitApp), keyEquivalent: "q")
        
        menu.items.forEach { $0.target = self }
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    private func showQuickAccessMenu() {
        let menu = NSMenu()
        
        // Add recent clipboard items
        let recentItems = Array(clipboardManager.clipboardItems.prefix(10))
        
        if recentItems.isEmpty {
            let item = NSMenuItem(title: "No clipboard items", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            for (index, clipboardItem) in recentItems.enumerated() {
                let title = String(clipboardItem.displayTitle.prefix(50))
                let menuItem = NSMenuItem(title: title, action: #selector(pasteClipboardItem(_:)), keyEquivalent: "")
                menuItem.target = self
                menuItem.tag = index
                menuItem.toolTip = clipboardItem.content
                
                // Add language indicator
                let languageText = " [\(clipboardItem.language.displayName)]"
                let attributedTitle = NSMutableAttributedString(string: title + languageText)
                attributedTitle.addAttributes([
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
                ], range: NSRange(location: title.count, length: languageText.count))
                menuItem.attributedTitle = attributedTitle
                
                menu.addItem(menuItem)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Show SwagCode", action: #selector(showMainWindow), keyEquivalent: "")
        menu.addItem(withTitle: "Clear All", action: #selector(clearAllItems), keyEquivalent: "")
        
        menu.items.forEach { item in
            if item.target == nil {
                item.target = self
            }
        }
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    private func updateStatusItemMenu() {
        // This method can be called when clipboard items change
        // For now, we'll update the tooltip
        if let button = statusItem?.button {
            let itemCount = clipboardManager.clipboardItems.count
            button.toolTip = "SwagCode - \(itemCount) clipboard items"
        }
    }
    
    // MARK: - Menu Actions
    
    @objc private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title.contains("SwagCode") || $0.contentViewController != nil }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc private func showPreferences() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }
    
    @objc private func pasteClipboardItem(_ sender: NSMenuItem) {
        let index = sender.tag
        guard index < clipboardManager.clipboardItems.count else { return }
        
        let item = clipboardManager.clipboardItems[index]
        clipboardManager.copyToClipboard(item)
    }
    
    @objc private func clearAllItems() {
        clipboardManager.clearAll()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
} 
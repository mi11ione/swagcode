//
//  StatusBarController.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import AppKit
import SwiftUI
import Combine

class StatusBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private let clipboardManager: ClipboardManager
    private let settings: AppSettings
    private var settingsObserver: AnyCancellable?
    
    init(clipboardManager: ClipboardManager, settings: AppSettings) {
        self.clipboardManager = clipboardManager
        self.settings = settings
        setupStatusBar()
        
        // Observe settings changes to update status bar
        settingsObserver = settings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatusItemMenu()
            }
        }
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
        menu.minimumWidth = 320
        
        // Add header with stats
        let headerItem = NSMenuItem()
        let headerView = createHeaderView()
        headerItem.view = headerView
        menu.addItem(headerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Add recent clipboard items
        let recentItems = Array(clipboardManager.clipboardItems.prefix(9))
        
        if recentItems.isEmpty {
            let emptyItem = NSMenuItem()
            let emptyView = createEmptyStateView()
            emptyItem.view = emptyView
            menu.addItem(emptyItem)
        } else {
            for (index, clipboardItem) in recentItems.enumerated() {
                let menuItem = NSMenuItem()
                let itemView = createClipboardItemView(clipboardItem, index: index)
                menuItem.view = itemView
                menuItem.target = self
                menuItem.action = #selector(pasteClipboardItem(_:))
                menuItem.tag = index
                menu.addItem(menuItem)
                
                // Add separator between items (except last)
                if index < recentItems.count - 1 {
                    menu.addItem(NSMenuItem.separator())
                }
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Add footer with actions
        let footerItem = NSMenuItem()
        let footerView = createFooterView()
        footerItem.view = footerView
        menu.addItem(footerItem)
        
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
    
    // MARK: - View Creation
    
    private func createHeaderView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 60))
        
        // Background
        let backgroundLayer = CALayer()
        backgroundLayer.frame = view.bounds
        backgroundLayer.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.1).cgColor
        backgroundLayer.cornerRadius = 8
        view.layer = backgroundLayer
        view.wantsLayer = true
        
        // Icon
        let iconView = NSImageView(frame: NSRect(x: 16, y: 20, width: 20, height: 20))
        iconView.image = NSImage(systemSymbolName: "doc.on.clipboard.fill", accessibilityDescription: nil)
        iconView.contentTintColor = NSColor.controlAccentColor
        view.addSubview(iconView)
        
        // Title
        let titleLabel = NSTextField(labelWithString: "SwagCode")
        titleLabel.frame = NSRect(x: 44, y: 32, width: 100, height: 16)
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = NSColor.labelColor
        view.addSubview(titleLabel)
        
        // Stats
        let itemCount = clipboardManager.clipboardItems.count
        let statsText = "\(itemCount) items"
        let statsLabel = NSTextField(labelWithString: statsText)
        statsLabel.frame = NSRect(x: 44, y: 16, width: 100, height: 14)
        statsLabel.font = NSFont.systemFont(ofSize: 12)
        statsLabel.textColor = NSColor.secondaryLabelColor
        view.addSubview(statsLabel)
        
        // Hotkey hint - use actual settings
        let hotkeyText = "\(settings.hotkeyModifiers.displayString)1-9"
        let hotkeyLabel = NSTextField(labelWithString: hotkeyText)
        hotkeyLabel.frame = NSRect(x: 260, y: 24, width: 44, height: 12)
        hotkeyLabel.font = NSFont.monospacedSystemFont(ofSize: 10, weight: .medium)
        hotkeyLabel.textColor = NSColor.tertiaryLabelColor
        hotkeyLabel.alignment = .right
        view.addSubview(hotkeyLabel)
        
        return view
    }
    
    private func createEmptyStateView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 80))
        
        // Icon
        let iconView = NSImageView(frame: NSRect(x: 150, y: 45, width: 20, height: 20))
        iconView.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
        iconView.contentTintColor = NSColor.tertiaryLabelColor
        view.addSubview(iconView)
        
        // Message
        let messageLabel = NSTextField(labelWithString: "No clipboard items yet")
        messageLabel.frame = NSRect(x: 60, y: 25, width: 200, height: 16)
        messageLabel.font = NSFont.systemFont(ofSize: 13)
        messageLabel.textColor = NSColor.secondaryLabelColor
        messageLabel.alignment = .center
        view.addSubview(messageLabel)
        
        // Hint
        let hintLabel = NSTextField(labelWithString: "Copy something to get started")
        hintLabel.frame = NSRect(x: 60, y: 8, width: 200, height: 14)
        hintLabel.font = NSFont.systemFont(ofSize: 11)
        hintLabel.textColor = NSColor.tertiaryLabelColor
        hintLabel.alignment = .center
        view.addSubview(hintLabel)
        
        return view
    }
    
    private func createClipboardItemView(_ item: ClipboardItem, index: Int) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 50))
        
        // Hover effect
        let trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: view,
            userInfo: nil
        )
        view.addTrackingArea(trackingArea)
        
        // Hotkey number
        let hotkeyLabel = NSTextField(labelWithString: "\(index + 1)")
        hotkeyLabel.frame = NSRect(x: 16, y: 18, width: 20, height: 14)
        hotkeyLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        hotkeyLabel.textColor = NSColor.controlAccentColor
        hotkeyLabel.alignment = .center
        hotkeyLabel.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.1)
        hotkeyLabel.isBordered = false
        hotkeyLabel.layer?.cornerRadius = 3
        view.addSubview(hotkeyLabel)
        
        // Language icon
        let languageIcon = getLanguageIcon(for: item.language)
        let iconView = NSImageView(frame: NSRect(x: 44, y: 26, width: 16, height: 16))
        iconView.image = NSImage(systemSymbolName: languageIcon, accessibilityDescription: nil)
        iconView.contentTintColor = getLanguageColor(for: item.language)
        view.addSubview(iconView)
        
        // Content preview
        let contentText = String(item.content.prefix(60))
        let contentLabel = NSTextField(labelWithString: contentText)
        contentLabel.frame = NSRect(x: 68, y: 26, width: 200, height: 16)
        contentLabel.font = NSFont.systemFont(ofSize: 12)
        contentLabel.textColor = NSColor.labelColor
        contentLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(contentLabel)
        
        // Language and time
        let timeAgo = formatTimeAgo(item.timestamp)
        let metaText = "\(item.language.displayName) • \(timeAgo)"
        let metaLabel = NSTextField(labelWithString: metaText)
        metaLabel.frame = NSRect(x: 68, y: 8, width: 200, height: 14)
        metaLabel.font = NSFont.systemFont(ofSize: 10)
        metaLabel.textColor = NSColor.secondaryLabelColor
        view.addSubview(metaLabel)
        
        // Copy button (appears on hover)
        let copyButton = NSButton(frame: NSRect(x: 280, y: 15, width: 24, height: 20))
        copyButton.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy")
        copyButton.isBordered = false
        copyButton.bezelStyle = .regularSquare
        copyButton.target = self
        copyButton.action = #selector(pasteClipboardItem(_:))
        copyButton.tag = index
        copyButton.alphaValue = 0.0
        view.addSubview(copyButton)
        
        return view
    }
    
    private func createFooterView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 40))
        
        // Show All button
        let showAllButton = NSButton(frame: NSRect(x: 16, y: 10, width: 80, height: 20))
        showAllButton.title = "Show All"
        showAllButton.font = NSFont.systemFont(ofSize: 11)
        showAllButton.bezelStyle = .rounded
        showAllButton.controlSize = .small
        showAllButton.target = self
        showAllButton.action = #selector(showMainWindow)
        view.addSubview(showAllButton)
        
        // Clear All button
        let clearButton = NSButton(frame: NSRect(x: 224, y: 10, width: 80, height: 20))
        clearButton.title = "Clear All"
        clearButton.font = NSFont.systemFont(ofSize: 11)
        clearButton.bezelStyle = .rounded
        clearButton.controlSize = .small
        clearButton.target = self
        clearButton.action = #selector(clearAllItems)
        view.addSubview(clearButton)
        
        return view
    }
    
    // MARK: - Helper Methods
    
    private func getLanguageIcon(for language: ProgrammingLanguage) -> String {
        switch language {
        case .swift: return "swift"
        case .javascript, .typescript: return "curlybraces"
        case .python: return "snake.fill"
        case .java, .kotlin: return "cup.and.saucer.fill"
        case .csharp: return "number"
        case .cpp, .c: return "c.circle.fill"
        case .go: return "g.circle.fill"
        case .rust: return "r.circle.fill"
        case .php: return "p.circle.fill"
        case .ruby: return "r.square.fill"
        case .html: return "chevron.left.forwardslash.chevron.right"
        case .css, .scss: return "paintbrush.fill"
        case .json: return "curlybraces.square.fill"
        case .xml: return "doc.text.fill"
        case .yaml: return "list.bullet.rectangle.fill"
        case .markdown: return "doc.richtext.fill"
        case .latex: return "doc.richtext.fill"
        case .sql: return "cylinder.fill"
        case .bash, .zsh: return "terminal.fill"
        case .dockerfile: return "shippingbox.fill"
        case .powershell: return "terminal.fill"
        case .toml: return "doc.fill"
        case .plain: return "doc.plaintext.fill"
        }
    }
    
    private func getLanguageColor(for language: ProgrammingLanguage) -> NSColor {
        switch language {
        case .swift: return NSColor.systemOrange
        case .javascript: return NSColor.systemYellow
        case .typescript: return NSColor.systemBlue
        case .python: return NSColor.systemGreen
        case .java: return NSColor.systemRed
        case .kotlin: return NSColor.systemPurple
        case .csharp: return NSColor.systemBlue
        case .cpp, .c: return NSColor.systemIndigo
        case .go: return NSColor.systemTeal
        case .rust: return NSColor.systemBrown
        case .php: return NSColor.systemPurple
        case .ruby: return NSColor.systemRed
        case .html: return NSColor.systemOrange
        case .css, .scss: return NSColor.systemBlue
        case .json: return NSColor.systemYellow
        case .xml: return NSColor.systemGreen
        case .yaml: return NSColor.systemCyan
        case .markdown: return NSColor.systemGray
        case .latex: return NSColor.systemGreen
        case .sql: return NSColor.systemBlue
        case .bash, .zsh: return NSColor.systemGreen
        case .dockerfile: return NSColor.systemBlue
        case .powershell: return NSColor.systemBlue
        case .toml: return NSColor.systemBrown
        case .plain: return NSColor.systemGray
        }
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
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
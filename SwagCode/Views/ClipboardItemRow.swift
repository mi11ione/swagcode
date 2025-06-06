//
//  ClipboardItemRow.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let index: Int
    @ObservedObject var clipboardManager: ClipboardManager
    @ObservedObject var settings: AppSettings
    @State private var isHovered = false
    @State private var showingFullContent = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content card
            VStack(alignment: .leading, spacing: 12) {
                // Header section
                headerSection
                
                // Content preview
                contentSection
                
                // Action buttons (shown on hover or when expanded)
                if isHovered || isExpanded {
                    actionButtonsSection
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }
            }
            .padding(16)
            .background(backgroundGradient)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: .black.opacity(0.1), radius: isHovered ? 8 : 2, x: 0, y: isHovered ? 4 : 1)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
            .contextMenu {
                contextMenuItems
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.3), value: showingFullContent)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            // Type and language indicators
            HStack(spacing: 8) {
                // Type indicator
                Image(systemName: item.type.icon)
                    .foregroundColor(item.type.color)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)
                
                // Language badge
                Text(item.language.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(item.language.color.opacity(0.15))
                    .foregroundColor(item.language.color)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(item.language.color.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            // Right side info
            VStack(alignment: .trailing, spacing: 4) {
                // Hotkey indicator
                if index < 9 {
                    HStack(spacing: 2) {
                        Text("\(settings.hotkeyModifiers.displayString)\(index + 1)")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor)
                            .cornerRadius(6)
                    }
                }
                
                // Timestamp
                Text(item.formattedTimestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Content preview or full content (no title)
            Group {
                if showingFullContent {
                    ScrollView {
                        SyntaxHighlightedText(
                            content: item.content, 
                            language: item.language,
                            showLineNumbers: settings.showLineNumbers,
                            fontSize: settings.fontSize
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 400)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                } else {
                    Text(item.content)
                        .font(.system(size: settings.fontSize, design: .monospaced))
                        .lineLimit(isMultiline ? 4 : 1)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
            }
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
        }
    }
    
    // MARK: - Helper Properties
    
    private var isMultiline: Bool {
        let contentTrimmed = item.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return contentTrimmed.components(separatedBy: .newlines).count > 1 || contentTrimmed.count > 100
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 8) {
            // Primary actions
            ActionButton(
                title: "Copy",
                icon: "doc.on.clipboard",
                style: .primary
            ) {
                clipboardManager.copyToClipboard(item)
                showCopyFeedback()
            }
            
            // Only show expand button for multiline content
            if isMultiline {
                ActionButton(
                    title: showingFullContent ? "Collapse" : "Expand",
                    icon: showingFullContent ? "chevron.up" : "chevron.down",
                    style: .secondary
                ) {
                    // Use faster animation for better responsiveness
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showingFullContent.toggle()
                    }
                }
            }
            
            ActionButton(
                title: "Share",
                icon: "square.and.arrow.up",
                style: .secondary
            ) {
                clipboardManager.shareItem(item)
            }
            
            Spacer()
            
            // Destructive action
            ActionButton(
                title: "Delete",
                icon: "trash",
                style: .destructive
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    clipboardManager.deleteItem(item)
                }
            }
        }
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        Button("Copy to Clipboard") {
            clipboardManager.copyToClipboard(item)
            showCopyFeedback()
        }
        
        // Only show expand option for multiline content
        if isMultiline {
            Button(showingFullContent ? "Collapse" : "Expand") {
                withAnimation(.easeInOut(duration: 0.15)) {
                    showingFullContent.toggle()
                }
            }
        }
        
        Button("Share") {
            clipboardManager.shareItem(item)
        }
        
        Divider()
        
        Button("Delete", role: .destructive) {
            withAnimation(.easeInOut(duration: 0.3)) {
                clipboardManager.deleteItem(item)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var backgroundGradient: LinearGradient {
        if isHovered {
            return LinearGradient(
                colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(NSColor.controlBackgroundColor)],
                startPoint: .center,
                endPoint: .center
            )
        }
    }
    
    private var borderColor: Color {
        if isHovered {
            return .accentColor.opacity(0.5)
        } else {
            return .secondary.opacity(0.2)
        }
    }
    
    private var borderWidth: CGFloat {
        isHovered ? 1.5 : 1
    }
    
    // MARK: - Helper Methods
    
    private func showCopyFeedback() {
        // Simple haptic feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let title: String
    let icon: String
    let style: ActionButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ActionButtonStyle {
        case primary, secondary, destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .accentColor
            case .secondary: return Color(NSColor.controlBackgroundColor)
            case .destructive: return .red.opacity(0.1)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            case .destructive: return .red
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary: return .clear
            case .secondary: return .secondary.opacity(0.3)
            case .destructive: return .red.opacity(0.3)
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    VStack(spacing: 16) {
        ClipboardItemRow(
            item: ClipboardItem(
                content: """
                func calculateFibonacci(_ n: Int) -> Int {
                    if n <= 1 {
                        return n
                    }
                    return calculateFibonacci(n - 1) + calculateFibonacci(n - 2)
                }
                """,
                timestamp: Date(),
                type: .code,
                language: .swift
            ),
            index: 0,
            clipboardManager: ClipboardManager(settings: AppSettings()),
            settings: AppSettings()
        )
        
        ClipboardItemRow(
            item: ClipboardItem(
                content: "https://developer.apple.com/documentation/swiftui",
                timestamp: Date().addingTimeInterval(-3600),
                type: .url,
                language: .plain
            ),
            index: 1,
            clipboardManager: ClipboardManager(settings: AppSettings()),
            settings: AppSettings()
        )
    }
    .padding()
    .frame(width: 600)
    .background(Color(NSColor.textBackgroundColor))
}
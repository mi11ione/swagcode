//
//  OnboardingView.swift
//  SwagCode
//
//  Created by Maksim Zoteev on 06.06.2025.
//

import SwiftUI
import Carbon

struct OnboardingView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var hotkeyManager: HotkeyManager
    let clipboardManager: ClipboardManager?
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: OnboardingStep = .welcome
    @State private var hasAccessibilityPermission = false
    @State private var hasInputMonitoringPermission = false
    @State private var isCheckingPermissions = false
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case features = 1
        case permissions = 2
        case hotkeys = 3
        case complete = 4
        
        var title: String {
            switch self {
            case .welcome: return "Welcome to SwagCode"
            case .features: return "Powerful Features"
            case .permissions: return "Permissions Setup"
            case .hotkeys: return "Configure Hotkeys"
            case .complete: return "You're All Set!"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            progressIndicator
            
            // Main content
            ZStack {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    stepContent(for: step)
                        .opacity(step == currentStep ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            
            // Navigation buttons
            navigationButtons
        }
        .frame(width: 720, height: 600)
        .background(
            LinearGradient(
                colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.textBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            checkPermissions()
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    Circle()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }
            
            Text(currentStep.title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.top, 32)
        .padding(.bottom, 24)
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private func stepContent(for step: OnboardingStep) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                switch step {
                case .welcome:
                    welcomeStep
                case .features:
                    featuresStep
                case .permissions:
                    permissionsStep
                case .hotkeys:
                    hotkeysStep
                case .complete:
                    completeStep
                }
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 32)
        }
    }
    
    // MARK: - Welcome Step
    
    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 80))
                .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            VStack(spacing: 12) {
                Text("Welcome to SwagCode")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("The ultimate clipboard manager for developers")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                Text("SwagCode automatically saves everything you copy and provides instant access with customizable hotkeys. Perfect for managing code snippets, URLs, and text.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                HStack(spacing: 24) {
                    FeatureBadge(icon: "curlybraces", text: "Syntax Highlighting")
                    FeatureBadge(icon: "keyboard", text: "Global Hotkeys")
                    FeatureBadge(icon: "magnifyingglass", text: "Smart Search")
                }
            }
        }
    }
    
    // MARK: - Features Step
    
    private var featuresStep: some View {
        VStack(spacing: 32) {
            Text("What makes SwagCode special?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "doc.on.clipboard.fill",
                    title: "Automatic Clipboard History",
                    description: "Every copy is automatically saved and organized. Never lose important snippets again.",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "curlybraces",
                    title: "Smart Syntax Highlighting",
                    description: "Supports 25+ programming languages with beautiful syntax highlighting.",
                    color: .green
                )
                
                FeatureRow(
                    icon: "keyboard",
                    title: "Lightning-Fast Hotkeys",
                    description: "Access your recent clips instantly with \(settings.hotkeyModifiers.displayString)1-9 keyboard shortcuts.",
                    color: .orange
                )
                
                FeatureRow(
                    icon: "magnifyingglass",
                    title: "Powerful Search & Filter",
                    description: "Find exactly what you need with smart search and language filtering.",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Permissions Step
    
    private var permissionsStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                let allPermissionsGranted = hasAccessibilityPermission && hasInputMonitoringPermission
                Image(systemName: allPermissionsGranted ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(allPermissionsGranted ? .green : .orange)
                
                Text("System Permissions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 20) {
                Text("SwagCode needs system permissions to monitor global hotkeys and clipboard events.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    PermissionRow(
                        icon: "accessibility",
                        title: "Accessibility",
                        description: "Required for global hotkey registration",
                        isGranted: hasAccessibilityPermission,
                        action: openAccessibilitySettings
                    )
                    
                    PermissionRow(
                        icon: "keyboard",
                        title: "Input Monitoring",
                        description: "Required to detect global keyboard shortcuts",
                        isGranted: hasInputMonitoringPermission,
                        action: openInputMonitoringSettings
                    )
                    
                    PermissionExplanationRow(
                        icon: "lock.shield",
                        title: "Privacy First",
                        description: "SwagCode only monitors keyboard shortcuts, not your typing"
                    )
                }
                
                VStack(spacing: 12) {
                    Button(action: checkPermissions) {
                        HStack {
                            if isCheckingPermissions {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Check Permissions")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(isCheckingPermissions)
                    
                    if hasAccessibilityPermission && hasInputMonitoringPermission {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("All permissions granted! You're ready to use global hotkeys.")
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // MARK: - Hotkeys Step
    
    private var hotkeysStep: some View {
        VStack(spacing: 32) {
            Text("Customize Your Hotkeys")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 24) {
                Text("Choose which modifier keys to use for your global hotkeys:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    HotkeyModifierToggle(
                        symbol: "⌘",
                        name: "Command",
                        isEnabled: $settings.hotkeyModifiers.command
                    )
                    
                    HotkeyModifierToggle(
                        symbol: "⌥",
                        name: "Option",
                        isEnabled: $settings.hotkeyModifiers.option
                    )
                    
                    HotkeyModifierToggle(
                        symbol: "⌃",
                        name: "Control",
                        isEnabled: $settings.hotkeyModifiers.control
                    )
                    
                    HotkeyModifierToggle(
                        symbol: "⇧",
                        name: "Shift",
                        isEnabled: $settings.hotkeyModifiers.shift
                    )
                }
                
                VStack(spacing: 12) {
                    Text("Your hotkeys will be:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(settings.hotkeyModifiers.displayString) + 1-9")
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor.opacity(0.3), lineWidth: 2)
                        )
                }
                
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        HotkeyExample(keys: "\(settings.hotkeyModifiers.displayString)1", description: "Latest item")
                        HotkeyExample(keys: "\(settings.hotkeyModifiers.displayString)2", description: "2nd latest")
                        HotkeyExample(keys: "\(settings.hotkeyModifiers.displayString)3", description: "3rd latest")
                    }
                    
                    Text("...and so on up to \(settings.hotkeyModifiers.displayString)9")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Complete Step
    
    private var completeStep: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("SwagCode is ready to supercharge your productivity")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                Text("Here's what happens next:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    NextStepRow(
                        number: "1",
                        title: "Start copying",
                        description: "Everything you copy will be automatically saved"
                    )
                    
                    NextStepRow(
                        number: "2",
                        title: "Use hotkeys",
                        description: "Press \(settings.hotkeyModifiers.displayString)1-9 to paste recent items"
                    )
                    
                    NextStepRow(
                        number: "3",
                        title: "Explore features",
                        description: "Check the menu bar icon for quick access and settings"
                    )
                }
            }
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack {
            if currentStep != .welcome {
                Button("Back") {
                    withAnimation {
                        currentStep = OnboardingStep(rawValue: currentStep.rawValue - 1) ?? .welcome
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            Spacer()
            
            Button(nextButtonTitle) {
                if currentStep == .complete {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1) ?? .complete
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(currentStep == .permissions && !(hasAccessibilityPermission && hasInputMonitoringPermission))
        }
        .padding(.horizontal, 60)
        .padding(.bottom, 40)
    }
    
    private var nextButtonTitle: String {
        switch currentStep {
        case .welcome: return "Get Started"
        case .features: return "Continue"
        case .permissions: return (hasAccessibilityPermission && hasInputMonitoringPermission) ? "Continue" : "Grant Permissions First"
        case .hotkeys: return "Continue"
        case .complete: return "Start Using SwagCode"
        }
    }
    
    // MARK: - Actions
    
    private func checkPermissions() {
        isCheckingPermissions = true
        
        // Check permissions on background queue to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let permissions = self.hotkeyManager.checkAllPermissions()
            
            DispatchQueue.main.async {
                self.hasAccessibilityPermission = permissions.accessibility
                self.hasInputMonitoringPermission = permissions.inputMonitoring
                self.isCheckingPermissions = false
            }
        }
    }
    
    private func openAccessibilitySettings() {
        // Try to open the specific accessibility settings page
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        } else {
            // Fallback to general security settings
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security")!)
        }
        
        // Also try to trigger the system prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        }
    }
    
    private func openInputMonitoringSettings() {
        // Try to open the specific input monitoring settings page
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
            NSWorkspace.shared.open(url)
        } else {
            // Fallback to general security settings
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security")!)
        }
    }
    
    private func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        settings.saveSettings()
        
        // Start hotkeys if permissions are available
        hotkeyManager.startHotkeys()
        
        // Start monitoring if enabled
        if settings.startMonitoringOnLaunch {
            clipboardManager?.startMonitoring()
        }
        
        // Close onboarding
        dismiss()
    }
}

// MARK: - Supporting Views

struct FeatureBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isGranted ? .green : .orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !isGranted {
                Button("Grant") {
                    action()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isGranted ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PermissionExplanationRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct HotkeyModifierToggle: View {
    let symbol: String
    let name: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Text(symbol)
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 32)
                
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .toggleStyle(.switch)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct HotkeyExample: View {
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
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct NextStepRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.accentColor)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    let settings = AppSettings()
    let clipboardManager = ClipboardManager(settings: settings)
    return OnboardingView(
        settings: settings,
        hotkeyManager: HotkeyManager(
            clipboardManager: clipboardManager,
            settings: settings
        ),
        clipboardManager: clipboardManager
    )
}
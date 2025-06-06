# SwagCode

A powerful, modern clipboard manager for developers built with SwiftUI for macOS.

![SwagCode Logo](https://img.shields.io/badge/SwagCode-Clipboard%20Manager-blue?style=for-the-badge&logo=apple)
![macOS](https://img.shields.io/badge/macOS-13.0+-blue?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Native-green?style=flat-square)

## Features

### 🚀 Core Features
- **Clipboard History Management** - Automatically saves up to 500 clipboard items with smart deduplication
- **Smart Language Detection** - Automatically detects programming languages from copied code
- **Syntax Highlighting** - Beautiful syntax highlighting for 25+ programming languages
- **Global Hotkeys** - Quick access with fully customizable keyboard shortcuts (⌃⌥1-9 by default)
- **Search & Filter** - Powerful search and filtering by language, content type, and text content
- **Auto-Paste** - Hotkeys automatically paste content to active application

### 🎨 Modern User Interface
- **Native macOS Design** - Beautiful, modern SwiftUI interface with Big Sur/Monterey styling
- **Status Bar Integration** - Elegant quick access menu from the menu bar
- **Modern Card Design** - Gradient backgrounds, shadows, and smooth animations
- **Interactive Elements** - Hover effects, expandable content, and smooth transitions
- **Smart Content Display** - Automatic title hiding for short items with expand functionality
- **Professional Typography** - Monospace fonts for code, optimized readability
- **Responsive Layout** - Adaptive interface that works on all screen sizes

### 🔧 Advanced Features
- **Smart Content Detection** - Automatically categorizes URLs, emails, code, and text with visual badges
- **Export/Import** - Backup and restore your clipboard history in JSON format
- **Smart Notifications** - Modern UserNotifications with separate settings for hotkeys and clipboard
- **Permission Management** - Dedicated permissions panel with status indicators and easy access
- **Data Management** - Configurable item limits, automatic cleanup, and storage statistics
- **Debounced Hotkeys** - Prevents accidental multiple triggers with intelligent timing

## Supported Languages

SwagCode provides syntax highlighting for:

**Programming Languages:**
- Swift, JavaScript, TypeScript, Python, Java, Kotlin
- C, C++, C#, Go, Rust, PHP, Ruby
- SQL, HTML, CSS, SCSS

**Configuration & Markup:**
- JSON, XML, YAML, TOML
- Markdown, LaTeX, Dockerfile
- Bash, Zsh, PowerShell

## Installation

### Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/SwagCode.git
cd SwagCode
```

2. Open the project in Xcode:
```bash
open SwagCode.xcodeproj
```

3. Build and run the project (⌘R)

### Permissions

SwagCode requires the following macOS permissions for full functionality:

- **Accessibility** - Required for global hotkey functionality and auto-paste
- **Input Monitoring** - Required for keyboard shortcut detection
- **Notifications** - Optional, for clipboard and hotkey notifications

The app includes a dedicated Permissions tab in settings with:
- Real-time permission status indicators
- Direct links to system settings
- One-click permission refresh
- Automatic troubleshooting guidance

## Usage

### Getting Started

1. **Launch SwagCode** - The app will appear in your menu bar
2. **Start Monitoring** - Clipboard monitoring starts automatically
3. **Copy Content** - Any text you copy will be saved automatically
4. **Access History** - Click the menu bar icon or use hotkeys

### Hotkeys

Default hotkeys (fully customizable in settings):
- `⌃⌥1` - Copy and paste most recent item
- `⌃⌥2` - Copy and paste second most recent item
- `⌃⌥3` - Copy and paste third most recent item
- ... and so on up to `⌃⌥9`

**Features:**
- **Auto-Paste** - Items are automatically pasted to the active application
- **Debounced Input** - Prevents accidental multiple triggers (300ms cooldown)
- **Visual Feedback** - Optional notifications when hotkeys are used
- **Smart Retry** - Automatic permission checking and retry logic

**Customization:** Hotkey combinations are fully customizable in settings. You can use any combination of Command (⌘), Option (⌥), Control (⌃), and Shift (⇧) modifiers with number keys 1-9.

### Menu Bar Actions

**Left Click:** Modern quick access menu with:
- Recent clipboard items with gradient backgrounds
- Visual type and language badges
- Hotkey indicators for quick reference
- Smooth hover animations

**Right Click:** Context menu with app controls and settings access

## Configuration

### Settings Overview

**General Settings:**
- Maximum clipboard items (10-500)
- Auto-detect programming language
- Show hotkey notifications
- Show clipboard notifications
- Start monitoring on launch

**Hotkey Settings:**
- Enable/disable global hotkeys
- Customize modifier keys (⌘, ⌥, ⌃, ⇧)
- Individual hotkey enable/disable
- Real-time hotkey testing

**Permissions:**
- Real-time Accessibility permission status
- Real-time Input Monitoring permission status
- Direct system settings access
- Permission refresh and troubleshooting

**Appearance Settings:**
- Syntax highlighting theme
- Font size (10-24pt)
- Show line numbers
- Modern card design elements

**Data Management:**
- View storage statistics
- Export/import clipboard data (JSON format)
- Clear all items with confirmation
- Automatic cleanup settings

## Architecture

SwagCode is built with modern SwiftUI and follows MVVM architecture with clean separation of concerns:

```
SwagCode/
├── Models/
│   ├── ClipboardItem.swift      # Data model for clipboard items
│   └── AppSettings.swift        # User preferences and settings
├── Views/
│   ├── ContentView.swift        # Main application interface
│   ├── ClipboardItemRow.swift   # Individual item display (legacy)
│   ├── ModernClipboardItemRow.swift # Modern card-based item display
│   ├── SettingsView.swift       # Tabbed settings interface
│   ├── SyntaxHighlighter.swift  # Syntax highlighting engine
│   └── DetailView.swift         # Detailed item view
├── Services/
│   ├── ClipboardManager.swift   # Clipboard monitoring with notifications
│   ├── HotkeyManager.swift      # Global hotkey handling with auto-paste
│   └── StatusBarController.swift # Modern menu bar integration
├── Extensions/
│   └── NSColor+Extensions.swift # Color extensions for modern UI
└── SwagCodeApp.swift           # App entry point with permission handling
```

**Key Architecture Features:**
- **ObservableObject** pattern for reactive UI updates
- **Combine** framework for data flow and notifications
- **UserDefaults** for persistent settings storage
- **Core Graphics** for advanced hotkey simulation
- **UserNotifications** for modern notification system

## Contributing

We welcome contributions! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Swift naming conventions
- Use SwiftUI best practices
- Add comments for complex logic
- Ensure accessibility support

## Privacy & Security

SwagCode is designed with privacy and security as top priorities:

**Data Privacy:**
- All clipboard data is stored locally on your Mac
- No data is transmitted to external servers
- Clipboard content never leaves your device
- No analytics or telemetry collection

**Security Features:**
- Secure permission handling with proper macOS integration
- Encrypted local storage for sensitive clipboard content
- Automatic cleanup of old clipboard items
- No third-party dependencies that could compromise security

**Transparency:**
- Open source codebase for full transparency
- Clear permission requests with detailed explanations
- User control over all data retention settings

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Technical Specifications

**System Requirements:**
- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel processor
- 50MB available disk space
- Accessibility and Input Monitoring permissions

**Performance:**
- Minimal memory footprint (~20MB RAM)
- Efficient clipboard monitoring with smart deduplication
- Optimized for battery life with intelligent background processing
- Fast search and filtering with indexed content

## Acknowledgments

- Built with SwiftUI and AppKit for native macOS experience
- Syntax highlighting inspired by popular code editors
- Icons from SF Symbols for consistent macOS design
- Modern UI design following Apple Human Interface Guidelines
- No third-party dependencies for maximum security and performance

## Support

If you encounter any issues or have feature requests:

1. Check the [Issues](https://github.com/yourusername/SwagCode/issues) page
2. Create a new issue with detailed information
3. Include your macOS version and steps to reproduce

---

**Made with ❤️ for developers by developers** 
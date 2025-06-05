# SwagCode

A powerful clipboard manager for developers built with SwiftUI for macOS.

![SwagCode Logo](https://img.shields.io/badge/SwagCode-Clipboard%20Manager-blue?style=for-the-badge&logo=apple)

## Features

### 🚀 Core Features
- **Clipboard History Management** - Automatically saves up to 500 clipboard items
- **Smart Language Detection** - Automatically detects programming languages from copied code
- **Syntax Highlighting** - Beautiful syntax highlighting for 25+ programming languages
- **Global Hotkeys** - Quick access with customizable keyboard shortcuts (⌘⌥1-9)
- **Search & Filter** - Powerful search and filtering by language and content type

### 🎨 User Interface
- **Native macOS Design** - Beautiful, modern SwiftUI interface
- **Status Bar Integration** - Quick access from the menu bar
- **Customizable Appearance** - Multiple themes and font size options
- **Responsive Layout** - Adaptive interface that works on all screen sizes

### 🔧 Advanced Features
- **Smart Content Detection** - Automatically categorizes URLs, emails, code, and text
- **Export/Import** - Backup and restore your clipboard history
- **Notifications** - Optional notifications for new clipboard items
- **Data Management** - Configurable item limits and automatic cleanup

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

SwagCode requires the following permissions:
- **Clipboard Access** - To monitor and manage clipboard content
- **Accessibility** - For global hotkey functionality
- **Notifications** - For optional clipboard notifications

## Usage

### Getting Started

1. **Launch SwagCode** - The app will appear in your menu bar
2. **Start Monitoring** - Clipboard monitoring starts automatically
3. **Copy Content** - Any text you copy will be saved automatically
4. **Access History** - Click the menu bar icon or use hotkeys

### Hotkeys

Default hotkeys (customizable in settings):
- `⌘⌥1` - Paste most recent item
- `⌘⌥2` - Paste second most recent item
- `⌘⌥3` - Paste third most recent item
- ... and so on up to `⌘⌥9`

### Menu Bar Actions

**Left Click:** Quick access menu with recent items
**Right Click:** Context menu with app controls

## Configuration

### Settings Overview

**General Settings:**
- Maximum clipboard items (10-500)
- Auto-detect programming language
- Show notifications
- Start monitoring on launch

**Hotkey Settings:**
- Enable/disable global hotkeys
- Customize modifier keys (⌘, ⌥, ⌃, ⇧)

**Appearance Settings:**
- Syntax highlighting theme
- Font size (10-24pt)
- Show line numbers

**Data Management:**
- View storage statistics
- Export/import clipboard data
- Clear all items

## Architecture

SwagCode is built with modern SwiftUI and follows MVVM architecture:

```
SwagCode/
├── Models/
│   ├── ClipboardItem.swift      # Data model for clipboard items
│   └── AppSettings.swift        # User preferences and settings
├── Views/
│   ├── ContentView.swift        # Main application interface
│   ├── ClipboardItemRow.swift   # Individual item display
│   ├── SettingsView.swift       # Settings interface
│   ├── SyntaxHighlighter.swift  # Syntax highlighting engine
│   └── DetailView.swift         # Detailed item view
├── Services/
│   ├── ClipboardManager.swift   # Clipboard monitoring service
│   ├── HotkeyManager.swift      # Global hotkey handling
│   └── StatusBarController.swift # Menu bar integration
└── SwagCodeApp.swift           # App entry point
```

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

## Privacy

SwagCode respects your privacy:
- All data is stored locally on your Mac
- No data is sent to external servers
- Clipboard content never leaves your device
- Optional telemetry can be disabled

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and AppKit
- Syntax highlighting inspired by popular code editors
- Icons from SF Symbols
- No third-party dependencies

## Support

If you encounter any issues or have feature requests:

1. Check the [Issues](https://github.com/yourusername/SwagCode/issues) page
2. Create a new issue with detailed information
3. Include your macOS version and steps to reproduce

---

**Made with ❤️ for developers by developers** 
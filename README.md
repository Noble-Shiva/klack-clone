<div align="center">

# ⌨️ Klack Clone

### *Bring the satisfying click of mechanical keyboards to every keystroke*

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%2011.0+-lightgrey.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow.svg)](https://github.com/Noble-Shiva/klack-clone)

<!-- Add your demo GIF here -->
<!-- ![Demo](assets/demo.gif) -->

</div>

---

## 🎯 What is Klack Clone?

**Klack Clone** is a native macOS application that transforms your typing experience by adding realistic mechanical keyboard sounds to every keystroke. Whether you're coding, writing, or browsing, enjoy the satisfying acoustic feedback of premium mechanical switches without the hardware.

> 💡 **Why Klack Clone?** Experience the joy of mechanical keyboards on your MacBook, without the weight, cost, or need to carry extra hardware!

---

## ✨ Features

### Core Functionality
- ⚡ **Zero-Lag Audio** - Sub-10ms latency from keystroke to sound
- 🎵 **Authentic Sounds** - Separate upstroke and downstroke audio for realistic feedback
- 🎲 **Organic Variation** - Pitch randomization mimics real mechanical keyboard behavior
- 🔊 **Volume Control** - Adjust sound levels to your preference
- 🎚️ **Multiple Profiles** - Switch between different mechanical switch types

### Keyboard Profiles (Planned)
- 🔵 Cherry MX Blue (Clicky)
- 🟤 Cherry MX Brown (Tactile)
- 🔴 Cherry MX Red (Linear)
- 🟡 Gateron Milky Yellow
- 🧈 NovelKeys Cream

### User Experience
- 📍 **Menu Bar App** - Unobtrusive, always accessible
- ⚡ **Quick Toggle** - Keyboard shortcut to enable/disable instantly
- 🎛️ **Settings Panel** - Customize your experience
- 🚀 **Launch at Startup** - Start automatically with macOS
- 🔒 **Privacy First** - Zero data collection, completely offline

---

## 🏗️ Architecture

Klack Clone is built with a modular agent-based architecture:

```
┌─────────────────────────────────────────────────────────┐
│                     Klack Clone                          │
├─────────────────────────────────────────────────────────┤
│  KeyboardMonitorAgent → AudioPlaybackAgent               │
│         ↓                      ↑                         │
│  PermissionsAgent      AudioLibraryAgent                 │
│         ↓                      ↑                         │
│     UIAgent  ←  ProfileManagerAgent  ←  SettingsAgent    │
│                        ↑                                 │
│                 RandomizationAgent                       │
└─────────────────────────────────────────────────────────┘
```

**Key Components:**
- 🎧 **AudioPlaybackAgent** - Ultra-low latency audio engine
- ⌨️ **KeyboardMonitorAgent** - Global keystroke capture
- 📚 **AudioLibraryAgent** - Sound asset management
- 🎨 **UIAgent** - Menu bar interface
- ⚙️ **SettingsAgent** - Preferences persistence

📖 [Read the full architecture documentation](AGENTS.md)

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Language** | Swift 5.9+ |
| **Audio Engine** | AVFoundation (AVAudioEngine, AVAudioPlayerNode) |
| **Event Monitoring** | Core Graphics (CGEvent API) |
| **UI Framework** | AppKit (NSStatusBar, NSMenu) |
| **Persistence** | UserDefaults |
| **Build System** | Xcode 15+ |

---

## 🚀 Roadmap

### Phase 1: Foundation (MVP) 🏗️
- [x] Project planning and architecture design
- [x] Basic project setup and structure
- [x] Global keyboard event monitoring
- [x] Simple audio playback
- [x] Menu bar presence with toggle
- [x] Accessibility permissions flow

### Phase 2: Core Features 🎵
- [x] Complete audio engine with zero-lag playback
- [x] Key-to-sound mapping system
- [x] Press/release event handling
- [x] Volume controls
- [x] Single sound profile implementation

### Phase 3: Enhanced Experience ✨
- [ ] Multiple sound profiles
- [x] Pitch randomization
- [ ] Settings window
- [ ] Keyboard shortcuts
- [ ] Launch at startup

### Phase 4: Polish & Optimization 💎
- [ ] Performance optimization
- [ ] Memory usage optimization
- [ ] UI refinements
- [ ] Comprehensive testing
- [ ] Bug fixes and edge cases

---

## 📋 Requirements

- **macOS**: 11.0 (Big Sur) or later
- **Xcode**: 15.0+ (for building from source)
- **Swift**: 5.9+
- **Permissions**: Accessibility (Input Monitoring)

## 🔨 Building from Source

Detailed build instructions are available in [KlackClone/README_BUILD.md](KlackClone/README_BUILD.md).

**Quick Start:**
```bash
cd KlackClone
swift package generate-xcodeproj
open KlackClone.xcodeproj
# Build and run with ⌘+R
```

Or build via command line:
```bash
cd KlackClone
swift build -c release
.build/release/KlackClone
```

---

## 🎯 Performance Goals

| Metric | Target |
|--------|--------|
| **Latency** | < 10ms per keystroke |
| **CPU Usage** | < 5% during active typing |
| **Memory** | < 100MB with multiple profiles |

---

## 📚 Documentation

- [Product Requirements Document (PRD)](PRD.md) - Complete product specifications
- [System Agents & Components](AGENTS.md) - Detailed architecture and design

---

## 🤝 Contributing

Contributions are welcome! This project is currently in active development. Please check out our [roadmap](#-roadmap) to see what we're working on.

### Development Setup

1. Clone the repository
```bash
git clone https://github.com/Noble-Shiva/klack-clone.git
cd klack-clone
```

2. Open the project in Xcode
```bash
cd KlackClone
swift package generate-xcodeproj
open KlackClone.xcodeproj
```

3. Build and run (⌘+R)

See [KlackClone/README_BUILD.md](KlackClone/README_BUILD.md) for detailed build instructions.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

Inspired by [Klack](https://tryklack.com/) - the original mechanical keyboard sound app for macOS.

---

## 📞 Contact & Support

- 🐛 **Bug Reports**: [Open an issue](https://github.com/Noble-Shiva/klack-clone/issues)
- 💡 **Feature Requests**: [Open an issue](https://github.com/Noble-Shiva/klack-clone/issues)
- ⭐ **Star this repo** if you find it interesting!

---

<div align="center">

**Made with ❤️ and ⌨️ clicks**

[![Star History](https://img.shields.io/github/stars/Noble-Shiva/klack-clone?style=social)](https://github.com/Noble-Shiva/klack-clone)

</div>

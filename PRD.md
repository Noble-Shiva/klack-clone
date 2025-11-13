# Klack-Clone - Product Requirements Document

## Product Overview

Klack-clone is a native macOS application that adds realistic mechanical keyboard sound effects to your typing experience. The app provides zero-lag audio feedback with high-quality sound samples that simulate various mechanical keyboard switch types.

## Architecture Overview

### 1. Project Setup
- Native macOS Swift application (not Catalyst/iOS)
- Menu bar app architecture (NSStatusItem, no dock icon)
- Minimum deployment target: macOS 11.0+ (for modern audio APIs)

### 2. Core Components

#### Audio Engine (Critical for zero-lag)
- Use `AVAudioEngine` with low-latency configuration
- Pre-load all sound samples into memory buffers
- Use `AVAudioPlayerNode` for instant playback
- Implement audio mixing for simultaneous key presses
- Target latency: < 10ms from key press to sound

#### Keyboard Event Monitoring
- Use `CGEvent` tap with `kCGEventTapOptionDefault`
- Monitor `keyDown` and `keyUp` events globally
- Requires Accessibility permissions (Input Monitoring)
- Map physical key codes to sound samples
- Handle modifier keys appropriately

#### Key Features

**Core Functionality**
- Separate upstroke/downstroke sounds (press & release)
- Pitch randomization (±5-10% variation per keystroke)
- Volume control (0-100%)
- Quick toggle on/off (global hotkey)
- Multiple sound profiles (Cherry MX, Gateron, etc.)

**User Interface**
- Menu bar icon with status indicator
- Dropdown menu for quick controls
- Volume slider
- Profile selector
- Enable/disable toggle
- Settings/preferences window

**Settings & Preferences**
- Sound profile selection
- Volume adjustment
- Keyboard shortcut customization
- Launch at startup option
- Audio output device selection

### 3. Technical Challenges

#### Performance Requirements
- **Latency**: Must be < 10ms from key press to sound
- **CPU Usage**: Minimal impact on system performance
- **Memory Usage**: Efficient management for 100+ audio samples loaded in memory
- **System Integration**: Clean menu bar UI without being intrusive

#### Permissions & Security
- Graceful handling of Accessibility permission requests
- Clear user guidance for enabling Input Monitoring
- Privacy-focused: no data collection or telemetry
- Completely offline operation

#### Audio Quality
- High-fidelity audio samples (44.1kHz or 48kHz)
- Proper audio mixing for simultaneous keypresses
- No audio artifacts or clicking
- Support for spatial audio (optional enhancement)

### 4. Sound Assets Strategy

Each keyboard profile requires comprehensive audio samples:
- **Sample Count**: ~100-200 samples per profile (50-100 keys × 2 directions)
- **Quality**: 16-bit or 24-bit, 44.1kHz minimum
- **Variety**: Slight variations for organic feel

#### Sourcing Options

**Option A: Record Your Own**
- Record actual mechanical keyboard sounds
- Pros: Authentic, customizable
- Cons: Requires equipment and time

**Option B: Royalty-Free Sound Libraries**
- Use existing mechanical keyboard sound packs
- Pros: Quick, professional quality
- Cons: Licensing considerations

**Option C: Synthetic Generation**
- Generate mechanical keyboard sounds programmatically
- Pros: Unlimited variations, no licensing issues
- Cons: May lack authenticity

#### Initial Sound Profiles (Priority Order)
1. Cherry MX Blue (clicky)
2. Cherry MX Brown (tactile)
3. Cherry MX Red (linear)
4. Gateron Milky Yellow
5. NovelKeys Cream

## Recommended Tech Stack

- **Language**: Swift 5.9+
- **Audio Framework**: AVFoundation (AVAudioEngine, AVAudioPlayerNode)
- **Event Monitoring**: Core Graphics (CGEvent)
- **UI Framework**: AppKit (NSStatusBar, NSMenu, NSWindow)
- **Persistence**: UserDefaults for settings
- **Build System**: Xcode 15+

## Development Phases

### Phase 1: Foundation (MVP)
- Basic project setup and structure
- Global keyboard event monitoring
- Simple audio playback (single sound)
- Menu bar presence with toggle
- Accessibility permissions flow

### Phase 2: Core Features
- Complete audio engine with zero-lag playback
- Key-to-sound mapping system
- Press/release event handling
- Volume controls
- Single sound profile implementation

### Phase 3: Enhanced Experience
- Multiple sound profiles
- Pitch randomization
- Settings window
- Keyboard shortcuts
- Launch at startup

### Phase 4: Polish & Optimization
- Performance optimization
- Memory usage optimization
- UI refinements
- Comprehensive testing
- Bug fixes and edge cases

## Success Metrics

- **Latency**: < 10ms from keystroke to sound
- **CPU Usage**: < 5% during active typing
- **Memory Footprint**: < 100MB with multiple profiles loaded
- **User Experience**: Seamless, satisfying audio feedback that enhances typing

## Future Enhancements (Post-MVP)

- Custom sound profile import
- Sound profile editor
- Visual keyboard overlay
- Typing statistics
- Multiple audio output device support
- iCloud settings sync
- Additional keyboard types (vintage typewriters, etc.)

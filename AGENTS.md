# Klack-Clone - System Agents & Components

## Overview

This document outlines the key system agents (components/modules) that make up the klack-clone architecture. Each agent has a specific responsibility and interfaces with other agents to create the complete typing sound experience.

## Core Agents

### 1. KeyboardMonitorAgent

**Responsibility**: Global keyboard event capture and processing

**Key Functions**:
- Monitor all keyboard events system-wide using CGEvent tap
- Capture both keyDown and keyUp events
- Map physical key codes to logical key identifiers
- Filter out modifier keys and special keys (optional)
- Emit events to AudioPlaybackAgent

**Technical Details**:
- Uses `CGEvent` API with `kCGEventTapOptionDefault`
- Requires Accessibility permissions (Input Monitoring)
- Runs on dedicated dispatch queue for performance
- Must be lightweight to avoid input lag

**Interfaces**:
- **Outputs to**: AudioPlaybackAgent (keystroke events)
- **Inputs from**: PermissionsAgent (authorization status)

**Key Challenges**:
- Minimal processing time to avoid input lag
- Proper handling when permissions are revoked
- Graceful degradation if event tap fails

---

### 2. AudioPlaybackAgent

**Responsibility**: Zero-latency audio playback

**Key Functions**:
- Maintain pre-loaded audio buffers in memory
- Play sounds instantly upon keystroke events
- Handle simultaneous key presses (audio mixing)
- Apply pitch variations for organic feel
- Manage volume levels

**Technical Details**:
- Uses `AVAudioEngine` with low-latency configuration
- `AVAudioPlayerNode` instances for each sound
- Pre-loaded `AVAudioPCMBuffer` for all samples
- Real-time pitch shifting using `AVAudioUnitTimePitch`

**Interfaces**:
- **Inputs from**: KeyboardMonitorAgent (keystroke events)
- **Inputs from**: AudioLibraryAgent (sound buffers)
- **Inputs from**: SettingsAgent (volume, enabled state)

**Key Challenges**:
- Achieving < 10ms latency
- Efficient audio mixing for rapid typing
- Memory management for multiple buffers

---

### 3. AudioLibraryAgent

**Responsibility**: Sound asset management and loading

**Key Functions**:
- Load audio files from disk/bundle
- Organize sounds by profile and key
- Provide pre-loaded audio buffers to AudioPlaybackAgent
- Handle profile switching
- Manage memory for loaded samples

**Technical Details**:
- Lazy loading of sound profiles (load on demand)
- Cache management for frequently used profiles
- Support for multiple audio formats (WAV, AIFF, CAF)

**Interfaces**:
- **Outputs to**: AudioPlaybackAgent (audio buffers)
- **Inputs from**: ProfileManagerAgent (active profile selection)

**Data Structure**:
```swift
struct SoundProfile {
    let name: String
    let keyDownSounds: [KeyCode: [AVAudioPCMBuffer]]
    let keyUpSounds: [KeyCode: [AVAudioPCMBuffer]]
}
```

**Key Challenges**:
- Memory efficiency with multiple profiles
- Fast profile switching without audio dropouts
- Handling missing sound files gracefully

---

### 4. ProfileManagerAgent

**Responsibility**: Sound profile management and switching

**Key Functions**:
- Maintain list of available sound profiles
- Handle profile selection and switching
- Coordinate with AudioLibraryAgent for loading
- Persist user's profile preference

**Technical Details**:
- Profiles stored in app bundle or user directory
- JSON/plist metadata for profile configuration
- Thread-safe profile switching

**Interfaces**:
- **Outputs to**: AudioLibraryAgent (profile load requests)
- **Inputs from**: UIAgent (user profile selection)
- **Inputs from**: SettingsAgent (saved preferences)

**Available Profiles** (Initial):
- Cherry MX Blue
- Cherry MX Brown
- Cherry MX Red
- Gateron Milky Yellow
- NovelKeys Cream

---

### 5. UIAgent (Menu Bar Interface)

**Responsibility**: User interface and interaction

**Key Functions**:
- Display menu bar icon and status
- Provide dropdown menu with controls
- Show volume slider and profile selector
- Handle user interactions
- Display settings window

**Technical Details**:
- Uses `NSStatusItem` for menu bar presence
- `NSMenu` for dropdown interface
- Custom `NSWindow` for settings panel
- Bindings to SettingsAgent for state persistence

**Interfaces**:
- **Inputs from**: All agents (for status updates)
- **Outputs to**: SettingsAgent (user preference changes)
- **Outputs to**: ProfileManagerAgent (profile selection)
- **Outputs to**: AudioPlaybackAgent (volume changes, toggle)

**UI Components**:
- Menu bar icon (with enabled/disabled states)
- Volume slider (0-100%)
- Profile selector dropdown
- Enable/disable toggle
- Settings button
- Quit option

---

### 6. SettingsAgent

**Responsibility**: Application settings and preferences management

**Key Functions**:
- Load and save user preferences
- Provide settings to other agents
- Handle settings migration
- Manage keyboard shortcuts
- Control launch-at-startup behavior

**Technical Details**:
- Uses `UserDefaults` for persistence
- Publishes changes via Combine or NotificationCenter
- Type-safe settings access

**Settings Managed**:
- Volume level (0-100)
- Selected profile name
- Enabled/disabled state
- Global keyboard shortcut
- Launch at startup
- Audio output device (optional)

**Interfaces**:
- **Inputs from**: UIAgent (user changes)
- **Outputs to**: All agents (settings values)

---

### 7. PermissionsAgent

**Responsibility**: System permissions management

**Key Functions**:
- Check Accessibility permissions status
- Request permissions from user
- Provide guidance UI for enabling permissions
- Monitor permission changes
- Handle permission denial gracefully

**Technical Details**:
- Uses `AXIsProcessTrusted()` for checking status
- `AXIsProcessTrustedWithOptions()` for prompting
- Periodic permission status checks

**Interfaces**:
- **Outputs to**: KeyboardMonitorAgent (permission status)
- **Outputs to**: UIAgent (permission prompt display)

**User Flow**:
1. App launch → Check permissions
2. If denied → Show guidance dialog
3. Open System Preferences → Security & Privacy → Accessibility
4. Add klack-clone to allowed apps
5. Retry monitoring

---

### 8. RandomizationAgent

**Responsibility**: Organic sound variation

**Key Functions**:
- Generate pitch variation values
- Provide randomization for sound selection (if multiple samples per key)
- Create natural-sounding typing rhythm

**Technical Details**:
- Pitch variation: ±5-10% random adjustment
- Seeded random for consistency (optional)
- Lightweight calculations

**Interfaces**:
- **Outputs to**: AudioPlaybackAgent (pitch adjustment values)

**Algorithm**:
```swift
func pitchVariation() -> Float {
    return Float.random(in: 0.95...1.05) // ±5%
}
```

---

## Agent Communication Flow

### Typical Keystroke Flow:

```
1. User presses key
   ↓
2. KeyboardMonitorAgent captures event
   ↓
3. KeyboardMonitorAgent identifies key code
   ↓
4. Event sent to AudioPlaybackAgent
   ↓
5. AudioPlaybackAgent requests pitch variation from RandomizationAgent
   ↓
6. AudioPlaybackAgent retrieves sound buffer from AudioLibraryAgent
   ↓
7. AudioPlaybackAgent plays sound with variation
   ↓
8. User hears satisfying click!
```

### Profile Switching Flow:

```
1. User selects new profile in UIAgent
   ↓
2. UIAgent notifies ProfileManagerAgent
   ↓
3. ProfileManagerAgent requests AudioLibraryAgent to load new profile
   ↓
4. AudioLibraryAgent loads sound buffers from disk
   ↓
5. AudioLibraryAgent notifies AudioPlaybackAgent of new buffers
   ↓
6. ProfileManagerAgent persists selection via SettingsAgent
```

## Implementation Priority

### Phase 1 (MVP):
1. PermissionsAgent
2. KeyboardMonitorAgent
3. AudioPlaybackAgent (basic)
4. AudioLibraryAgent (single profile)
5. UIAgent (minimal menu bar)

### Phase 2 (Enhanced):
6. SettingsAgent
7. ProfileManagerAgent
8. RandomizationAgent

### Phase 3 (Polish):
- Inter-agent optimization
- Error handling and recovery
- Performance monitoring

## Design Patterns

- **Observer Pattern**: Settings changes broadcast to interested agents
- **Singleton Pattern**: Each agent as a shared instance (where appropriate)
- **Factory Pattern**: AudioLibraryAgent creates audio buffers
- **Strategy Pattern**: Different audio playback strategies per profile
- **Command Pattern**: Keyboard events as command objects

## Testing Considerations

Each agent should be:
- **Unit testable**: Mock dependencies for isolation
- **Performance testable**: Measure latency and resource usage
- **Integration testable**: Test agent communication
- **Stress testable**: Handle rapid events and edge cases

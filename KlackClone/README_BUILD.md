# Building KlackClone

## Requirements
- macOS 11.0 (Big Sur) or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Build Instructions

### Option 1: Using Xcode

1. **Generate Xcode Project**
   ```bash
   cd KlackClone
   swift package generate-xcodeproj
   ```

   Or use the newer method:
   ```bash
   xcodebuild -resolvePackageDependencies
   open Package.swift
   ```

2. **Configure Code Signing**
   - Open the project in Xcode
   - Select the KlackClone target
   - Go to "Signing & Capabilities"
   - Select your development team
   - Ensure "Automatically manage signing" is enabled

3. **Build and Run**
   - Press ⌘+R or click the Run button
   - Grant Accessibility permission when prompted
   - The app will appear in the menu bar

### Option 2: Command Line Build

```bash
cd KlackClone
swift build -c release
```

The built executable will be at:
```
.build/release/KlackClone
```

## First Run Setup

1. **Grant Accessibility Permission**
   - On first launch, you'll be prompted to grant Accessibility permission
   - Click "Open System Preferences"
   - In System Preferences > Security & Privacy > Privacy > Accessibility
   - Click the lock icon to make changes
   - Add KlackClone to the list
   - Check the box next to KlackClone

2. **Start Typing!**
   - Once permission is granted, the app will automatically start monitoring
   - You should hear click sounds when typing
   - Use the menu bar icon to control volume and settings

## Troubleshooting

### No Sound
- Check volume in menu bar (ensure it's not 0%)
- Verify "Enabled" is checked in the menu
- Check system volume is not muted

### Permission Issues
- Go to System Preferences > Security & Privacy > Privacy > Accessibility
- Remove KlackClone and re-add it
- Restart the app

### Build Errors
- Ensure you're using Xcode 15+ and macOS 11+
- Clean build folder: ⌘+Shift+K
- Reset package cache: `swift package reset`

## Development

### Project Structure
```
KlackClone/
├── KlackClone/
│   ├── AppDelegate.swift          # Main app entry point
│   ├── Agents/                     # All agent modules
│   │   ├── PermissionsAgent.swift
│   │   ├── KeyboardMonitorAgent.swift
│   │   ├── AudioPlaybackAgent.swift
│   │   ├── AudioLibraryAgent.swift
│   │   ├── SettingsAgent.swift
│   │   ├── UIAgent.swift
│   │   ├── RandomizationAgent.swift
│   │   └── ProfileManagerAgent.swift
│   ├── Resources/                  # Audio files, assets
│   ├── Info.plist                  # App configuration
│   └── KlackClone.entitlements     # App permissions
└── Package.swift                   # Swift Package Manager config
```

### Adding Audio Files

1. Create sound profile folder in `Resources/Sounds/[ProfileName]/`
2. Add WAV or AIFF files named by key code (e.g., `0_down.wav`, `0_up.wav`)
3. Update AudioLibraryAgent to load from bundle

## Distribution

### Creating a Release Build

```bash
cd KlackClone
swift build -c release
```

### Code Signing for Distribution

```bash
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: YOUR NAME" \
  .build/release/KlackClone
```

### Creating a DMG

```bash
# Install create-dmg if needed
brew install create-dmg

# Create DMG
create-dmg \
  --volname "KlackClone" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "KlackClone.app" 175 120 \
  --hide-extension "KlackClone.app" \
  --app-drop-link 425 120 \
  "KlackClone.dmg" \
  ".build/release/"
```

## License

MIT License - See LICENSE file for details

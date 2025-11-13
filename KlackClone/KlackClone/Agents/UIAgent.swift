//
//  UIAgent.swift
//  KlackClone
//
//  Menu bar interface for KlackClone
//

import Cocoa

class UIAgent: NSObject {

    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private let settings: SettingsAgent
    private let profileManager: ProfileManagerAgent
    private let audioPlayback: AudioPlaybackAgent
    private let keyboardMonitor: KeyboardMonitorAgent

    private var menu: NSMenu!
    private var enabledMenuItem: NSMenuItem!
    private var volumeSlider: NSSlider!

    // MARK: - Initialization

    init(settings: SettingsAgent,
         profileManager: ProfileManagerAgent,
         audioPlayback: AudioPlaybackAgent,
         keyboardMonitor: KeyboardMonitorAgent) {

        self.settings = settings
        self.profileManager = profileManager
        self.audioPlayback = audioPlayback
        self.keyboardMonitor = keyboardMonitor

        super.init()

        print("🎨 UIAgent initialized")
        setupMenuBar()
        observeSettings()
    }

    // MARK: - Menu Bar Setup

    private func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: "KlackClone")
            button.imagePosition = .imageLeading
        }

        // Create menu
        menu = NSMenu()

        // Title
        let titleItem = NSMenuItem()
        titleItem.title = "⌨️  KlackClone"
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        menu.addItem(NSMenuItem.separator())

        // Enabled toggle
        enabledMenuItem = NSMenuItem(
            title: "Enabled",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        enabledMenuItem.target = self
        enabledMenuItem.state = settings.isEnabled ? .on : .off
        menu.addItem(enabledMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Volume control
        let volumeItem = NSMenuItem()
        volumeItem.title = "Volume"
        volumeItem.isEnabled = false
        menu.addItem(volumeItem)

        let volumeSliderItem = NSMenuItem()
        volumeSlider = NSSlider(value: settings.volume, minValue: 0, maxValue: 100, target: self, action: #selector(volumeChanged))
        volumeSlider.frame = NSRect(x: 0, y: 0, width: 200, height: 25)
        volumeSliderItem.view = createVolumeView()
        menu.addItem(volumeSliderItem)

        menu.addItem(NSMenuItem.separator())

        // Profile selection
        createProfileMenu()

        menu.addItem(NSMenuItem.separator())

        // Launch at Startup
        let launchAtStartupItem = NSMenuItem(
            title: "Launch at Startup",
            action: #selector(toggleLaunchAtStartup),
            keyEquivalent: ""
        )
        launchAtStartupItem.target = self
        launchAtStartupItem.state = settings.launchAtStartup ? .on : .off
        menu.addItem(launchAtStartupItem)

        menu.addItem(NSMenuItem.separator())

        // About
        menu.addItem(NSMenuItem(
            title: "About KlackClone",
            action: #selector(showAbout),
            keyEquivalent: ""
        ))

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(
            title: "Quit KlackClone",
            action: #selector(quit),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu

        print("✅ Menu bar setup complete")
    }

    private func createVolumeView() -> NSView {
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 30))

        // Volume slider
        volumeSlider = NSSlider(value: settings.volume, minValue: 0, maxValue: 100, target: self, action: #selector(volumeChanged))
        volumeSlider.frame = NSRect(x: 20, y: 5, width: 200, height: 25)
        containerView.addSubview(volumeSlider)

        return containerView
    }

    // MARK: - Actions

    @objc private func toggleEnabled() {
        settings.isEnabled.toggle()
        enabledMenuItem.state = settings.isEnabled ? .on : .off
        updateStatusIcon()

        print("🎨 Sound \(settings.isEnabled ? "enabled" : "disabled")")
    }

    @objc private func volumeChanged() {
        let newVolume = volumeSlider.doubleValue
        settings.volume = newVolume
        audioPlayback.setVolume(Float(newVolume))

        print("🎨 Volume changed to \(Int(newVolume))%")
    }

    @objc private func toggleLaunchAtStartup(_ sender: NSMenuItem) {
        settings.launchAtStartup.toggle()
        sender.state = settings.launchAtStartup ? .on : .off

        print("🎨 Launch at startup \(settings.launchAtStartup ? "enabled" : "disabled")")
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "KlackClone"
        alert.informativeText = """
        Version 1.0.0 (MVP)

        Bring the satisfying click of mechanical keyboards to every keystroke.

        Made with ❤️ and ⌨️ clicks

        © 2025 KlackClone
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Profile Menu

    private func createProfileMenu() {
        let profileMenuItem = NSMenuItem()
        profileMenuItem.title = "Sound Profile"

        let profileSubmenu = NSMenu()

        // Get all available profiles
        let profiles = profileManager.getAvailableProfiles()
        let currentProfile = profileManager.currentProfile

        for profileName in profiles {
            let item = NSMenuItem(
                title: profileName,
                action: #selector(profileSelected(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = profileName
            item.state = (profileName == currentProfile) ? .on : .off
            profileSubmenu.addItem(item)
        }

        profileMenuItem.submenu = profileSubmenu
        menu.addItem(profileMenuItem)
    }

    @objc private func profileSelected(_ sender: NSMenuItem) {
        guard let profileName = sender.representedObject as? String else { return }

        profileManager.switchProfile(to: profileName)

        // Update checkmarks
        if let profileMenu = sender.menu {
            for item in profileMenu.items {
                item.state = .off
            }
            sender.state = .on
        }

        print("🎨 Profile selected: \(profileName)")
    }

    // MARK: - UI Updates

    private func updateStatusIcon() {
        if let button = statusItem.button {
            let iconName = settings.isEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "KlackClone")
        }
    }

    // MARK: - Settings Observer

    private func observeSettings() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: .settingsDidChange,
            object: nil
        )
    }

    @objc private func settingsChanged() {
        enabledMenuItem.state = settings.isEnabled ? .on : .off
        volumeSlider.doubleValue = settings.volume
        updateStatusIcon()
    }
}

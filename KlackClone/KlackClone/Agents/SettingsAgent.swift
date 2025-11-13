//
//  SettingsAgent.swift
//  KlackClone
//
//  Manages application settings and user preferences
//

import Foundation

class SettingsAgent {

    // MARK: - Settings Keys

    private enum Keys {
        static let isEnabled = "klack.isEnabled"
        static let volume = "klack.volume"
        static let selectedProfile = "klack.selectedProfile"
        static let launchAtStartup = "klack.launchAtStartup"
    }

    // MARK: - Properties

    private let defaults = UserDefaults.standard

    // Public accessors
    var isEnabled: Bool {
        get { defaults.bool(forKey: Keys.isEnabled, defaultValue: true) }
        set {
            defaults.set(newValue, forKey: Keys.isEnabled)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var volume: Double {
        get { defaults.double(forKey: Keys.volume, defaultValue: 50.0) }
        set {
            let clampedValue = max(0, min(100, newValue))
            defaults.set(clampedValue, forKey: Keys.volume)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var selectedProfile: String {
        get { defaults.string(forKey: Keys.selectedProfile) ?? "Default" }
        set {
            defaults.set(newValue, forKey: Keys.selectedProfile)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var launchAtStartup: Bool {
        get { defaults.bool(forKey: Keys.launchAtStartup, defaultValue: false) }
        set {
            defaults.set(newValue, forKey: Keys.launchAtStartup)
            configureLaunchAtStartup(enabled: newValue)
        }
    }

    // MARK: - Initialization

    init() {
        print("⚙️  SettingsAgent initialized")
        loadDefaults()
    }

    private func loadDefaults() {
        // Ensure default values are set
        if defaults.object(forKey: Keys.isEnabled) == nil {
            defaults.set(true, forKey: Keys.isEnabled)
        }

        if defaults.object(forKey: Keys.volume) == nil {
            defaults.set(50.0, forKey: Keys.volume)
        }

        if defaults.object(forKey: Keys.selectedProfile) == nil {
            defaults.set("Default", forKey: Keys.selectedProfile)
        }

        print("✅ Settings loaded - Enabled: \(isEnabled), Volume: \(volume)%, Profile: \(selectedProfile)")
    }

    // MARK: - Launch at Startup

    private func configureLaunchAtStartup(enabled: Bool) {
        // Note: This requires LSSharedFileList or LoginItems API
        // For MVP, we'll add this in Phase 3
        print("⚙️  Launch at startup: \(enabled) (not yet implemented)")
    }

    // MARK: - Reset

    func resetToDefaults() {
        isEnabled = true
        volume = 50.0
        selectedProfile = "Default"
        launchAtStartup = false

        print("⚙️  Settings reset to defaults")
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }

    func double(forKey key: String, defaultValue: Double) -> Double {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return double(forKey: key)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}

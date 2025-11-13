//
//  ProfileManagerAgent.swift
//  KlackClone
//
//  Manages sound profiles and profile switching
//

import Foundation

class ProfileManagerAgent {

    // MARK: - Properties

    private let audioLibrary: AudioLibraryAgent
    private let settings: SettingsAgent

    private var availableProfiles: [String] = ["Default"]

    var currentProfile: String {
        settings.selectedProfile
    }

    // MARK: - Initialization

    init(audioLibrary: AudioLibraryAgent, settings: SettingsAgent) {
        self.audioLibrary = audioLibrary
        self.settings = settings

        print("🎚️  ProfileManagerAgent initialized")

        // Load the saved profile
        loadCurrentProfile()
    }

    // MARK: - Profile Management

    func getAvailableProfiles() -> [String] {
        return availableProfiles
    }

    func switchProfile(to name: String) {
        guard availableProfiles.contains(name) else {
            print("⚠️  Profile not found: \(name)")
            return
        }

        print("🎚️  Switching to profile: \(name)")

        audioLibrary.loadProfile(named: name)
        settings.selectedProfile = name

        // Notify UI
        NotificationCenter.default.post(name: .profileDidChange, object: nil)

        print("✅ Profile switched to: \(name)")
    }

    private func loadCurrentProfile() {
        let profileName = settings.selectedProfile
        audioLibrary.loadProfile(named: profileName)
        print("✅ Loaded profile: \(profileName)")
    }

    // MARK: - Future: Custom Profiles

    func addCustomProfile(named name: String, fromPath path: String) {
        // TODO: Implement in Phase 4
        print("🎚️  Custom profile support coming in Phase 4")
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let profileDidChange = Notification.Name("profileDidChange")
}

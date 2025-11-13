//
//  AppDelegate.swift
//  KlackClone
//
//  Created by Claude on 11/13/2025.
//  Copyright © 2025 KlackClone. All rights reserved.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Agents
    private var permissionsAgent: PermissionsAgent!
    private var keyboardMonitorAgent: KeyboardMonitorAgent!
    private var audioPlaybackAgent: AudioPlaybackAgent!
    private var audioLibraryAgent: AudioLibraryAgent!
    private var settingsAgent: SettingsAgent!
    private var uiAgent: UIAgent!
    private var randomizationAgent: RandomizationAgent!
    private var profileManagerAgent: ProfileManagerAgent!

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("🚀 KlackClone starting up...")

        // Initialize agents in correct order
        initializeAgents()

        // Check permissions
        checkPermissions()

        print("✅ KlackClone ready!")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("👋 KlackClone shutting down...")

        // Clean up agents
        keyboardMonitorAgent?.stop()
        audioPlaybackAgent?.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Initialization

    private func initializeAgents() {
        // 1. Settings Agent (needed by others)
        settingsAgent = SettingsAgent()

        // 2. Randomization Agent (lightweight)
        randomizationAgent = RandomizationAgent()

        // 3. Audio Library Agent
        audioLibraryAgent = AudioLibraryAgent()

        // 4. Profile Manager Agent
        profileManagerAgent = ProfileManagerAgent(
            audioLibrary: audioLibraryAgent,
            settings: settingsAgent
        )

        // 5. Audio Playback Agent
        audioPlaybackAgent = AudioPlaybackAgent(
            audioLibrary: audioLibraryAgent,
            randomization: randomizationAgent,
            settings: settingsAgent
        )

        // 6. Permissions Agent
        permissionsAgent = PermissionsAgent()

        // 7. Keyboard Monitor Agent
        keyboardMonitorAgent = KeyboardMonitorAgent(
            audioPlayback: audioPlaybackAgent,
            permissions: permissionsAgent,
            settings: settingsAgent
        )

        // 8. UI Agent (menu bar)
        uiAgent = UIAgent(
            settings: settingsAgent,
            profileManager: profileManagerAgent,
            audioPlayback: audioPlaybackAgent,
            keyboardMonitor: keyboardMonitorAgent
        )

        print("✅ All agents initialized")
    }

    private func checkPermissions() {
        if !permissionsAgent.hasAccessibilityPermission() {
            print("⚠️  Accessibility permission not granted")
            permissionsAgent.requestAccessibilityPermission()
        } else {
            print("✅ Accessibility permission granted")
            keyboardMonitorAgent.start()
        }
    }
}

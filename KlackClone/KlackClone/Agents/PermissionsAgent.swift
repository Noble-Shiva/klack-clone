//
//  PermissionsAgent.swift
//  KlackClone
//
//  Manages macOS Accessibility permissions required for global keyboard monitoring
//

import Cocoa
import ApplicationServices

class PermissionsAgent {

    // MARK: - Properties

    private var permissionCheckTimer: Timer?

    // MARK: - Initialization

    init() {
        print("🔐 PermissionsAgent initialized")
    }

    deinit {
        permissionCheckTimer?.invalidate()
    }

    // MARK: - Permission Checking

    /// Check if the app has Accessibility permission
    func hasAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false]
        let trusted = AXIsProcessTrustedWithOptions(options)
        return trusted
    }

    /// Request Accessibility permission from the user
    func requestAccessibilityPermission() {
        print("🔐 Requesting Accessibility permission...")

        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options)

        if !trusted {
            showPermissionGuidanceDialog()
            startPermissionMonitoring()
        }
    }

    // MARK: - UI Helpers

    private func showPermissionGuidanceDialog() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = """
            KlackClone needs Accessibility permission to monitor your keyboard and play sounds.

            Steps:
            1. Click "Open System Preferences" below
            2. Enable KlackClone in the Accessibility list
            3. Restart KlackClone

            Your privacy is protected - we only monitor keystrokes to play sounds locally. No data is collected or sent anywhere.
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Cancel")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                self.openAccessibilityPreferences()
            }
        }
    }

    private func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    // MARK: - Permission Monitoring

    private func startPermissionMonitoring() {
        // Check every 2 seconds if permission was granted
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.hasAccessibilityPermission() {
                print("✅ Accessibility permission granted!")
                self.permissionCheckTimer?.invalidate()

                // Notify that permission was granted
                NotificationCenter.default.post(name: .accessibilityPermissionGranted, object: nil)
            }
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let accessibilityPermissionGranted = Notification.Name("accessibilityPermissionGranted")
}

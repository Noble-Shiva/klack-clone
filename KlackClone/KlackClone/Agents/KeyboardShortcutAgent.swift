//
//  KeyboardShortcutAgent.swift
//  KlackClone
//
//  Handles global keyboard shortcuts for quick toggle
//

import Cocoa
import Carbon

class KeyboardShortcutAgent {

    // MARK: - Properties

    private let settings: SettingsAgent
    private var eventHandler: EventHandlerRef?
    private var eventHotKeyRef: EventHotKeyRef?

    // Default shortcut: Command + Shift + K
    private let defaultKeyCode: UInt32 = 40 // K key
    private let defaultModifiers: UInt32 = UInt32(cmdKey | shiftKey)

    // MARK: - Initialization

    init(settings: SettingsAgent) {
        self.settings = settings

        print("⌨️  KeyboardShortcutAgent initialized")
        registerGlobalHotkey()
    }

    deinit {
        unregisterGlobalHotkey()
    }

    // MARK: - Hotkey Registration

    private func registerGlobalHotkey() {
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        // Install event handler
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                guard let userData = userData else { return noErr }

                let agent = Unmanaged<KeyboardShortcutAgent>.fromOpaque(userData).takeUnretainedValue()
                agent.hotKeyPressed()

                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard status == noErr else {
            print("❌ Failed to install event handler")
            return
        }

        // Register hot key
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(fourCharCode: "klck")
        hotKeyID.id = 1

        let registerStatus = RegisterEventHotKey(
            defaultKeyCode,
            defaultModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKeyRef
        )

        if registerStatus == noErr {
            print("✅ Global hotkey registered: ⌘⇧K (Command+Shift+K)")
        } else {
            print("❌ Failed to register hotkey")
        }
    }

    private func unregisterGlobalHotkey() {
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }

        if let hotKeyRef = eventHotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }

        print("⌨️  Global hotkey unregistered")
    }

    // MARK: - Hotkey Action

    private func hotKeyPressed() {
        // Toggle enabled state
        settings.isEnabled.toggle()

        print("⌨️  Hotkey pressed! Klack is now \(settings.isEnabled ? "enabled" : "disabled")")

        // Show temporary notification
        showNotification(enabled: settings.isEnabled)
    }

    private func showNotification(enabled: Bool) {
        let notification = NSUserNotification()
        notification.title = "KlackClone"
        notification.informativeText = enabled ? "Sound enabled" : "Sound disabled"
        notification.soundName = nil

        NSUserNotificationCenter.default.deliver(notification)
    }

    // MARK: - Helpers

    private func fourCharCode(_ string: String) -> FourCharCode {
        assert(string.count == 4, "String must be exactly 4 characters")
        var result: FourCharCode = 0
        for char in string.utf16 {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}

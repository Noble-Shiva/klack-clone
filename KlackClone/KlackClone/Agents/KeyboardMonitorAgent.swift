//
//  KeyboardMonitorAgent.swift
//  KlackClone
//
//  Monitors global keyboard events using CGEvent tap
//

import Cocoa
import CoreGraphics

class KeyboardMonitorAgent {

    // MARK: - Properties

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private let audioPlayback: AudioPlaybackAgent
    private let permissions: PermissionsAgent
    private let settings: SettingsAgent

    private var isRunning = false

    // MARK: - Initialization

    init(audioPlayback: AudioPlaybackAgent, permissions: PermissionsAgent, settings: SettingsAgent) {
        self.audioPlayback = audioPlayback
        self.permissions = permissions
        self.settings = settings

        print("⌨️  KeyboardMonitorAgent initialized")

        // Listen for permission changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(permissionGranted),
            name: .accessibilityPermissionGranted,
            object: nil
        )
    }

    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Control Methods

    func start() {
        guard !isRunning else {
            print("⚠️  KeyboardMonitorAgent already running")
            return
        }

        guard permissions.hasAccessibilityPermission() else {
            print("⚠️  Cannot start KeyboardMonitorAgent: missing Accessibility permission")
            return
        }

        print("⌨️  Starting keyboard monitoring...")

        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }

                let agent = Unmanaged<KeyboardMonitorAgent>.fromOpaque(refcon).takeUnretainedValue()
                agent.handleKeyboardEvent(type: type, event: event)

                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("❌ Failed to create event tap")
            return
        }

        self.eventTap = eventTap

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

        CGEvent.tapEnable(tap: eventTap, enable: true)

        self.runLoopSource = runLoopSource
        self.isRunning = true

        print("✅ Keyboard monitoring started")
    }

    func stop() {
        guard isRunning else { return }

        print("⌨️  Stopping keyboard monitoring...")

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isRunning = false

        print("✅ Keyboard monitoring stopped")
    }

    // MARK: - Event Handling

    private func handleKeyboardEvent(type: CGEventType, event: CGEvent) {
        // Check if sound is enabled
        guard settings.isEnabled else { return }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        switch type {
        case .keyDown:
            audioPlayback.playKeyDownSound(for: Int(keyCode))

        case .keyUp:
            audioPlayback.playKeyUpSound(for: Int(keyCode))

        default:
            break
        }
    }

    // MARK: - Notification Handlers

    @objc private func permissionGranted() {
        print("✅ Permission granted notification received")
        start()
    }
}

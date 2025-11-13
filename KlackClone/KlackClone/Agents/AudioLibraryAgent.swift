//
//  AudioLibraryAgent.swift
//  KlackClone
//
//  Manages sound assets and provides pre-loaded audio buffers
//

import AVFoundation
import Cocoa

class AudioLibraryAgent {

    // MARK: - Properties

    private var currentProfile: SoundProfile?
    private var loadedProfiles: [String: SoundProfile] = [:]

    // MARK: - Initialization

    init() {
        print("📚 AudioLibraryAgent initialized")
        loadDefaultProfile()
    }

    // MARK: - Sound Retrieval

    func getKeyDownSound(for keyCode: Int) -> AVAudioPCMBuffer? {
        return currentProfile?.keyDownSounds[keyCode]
    }

    func getKeyUpSound(for keyCode: Int) -> AVAudioPCMBuffer? {
        return currentProfile?.keyUpSounds[keyCode]
    }

    // MARK: - Profile Management

    func loadProfile(named name: String) {
        // Check if already loaded
        if let profile = loadedProfiles[name] {
            currentProfile = profile
            print("✅ Switched to profile: \(name)")
            return
        }

        // Load new profile
        print("📚 Loading profile: \(name)...")

        if let profile = createProfile(named: name) {
            loadedProfiles[name] = profile
            currentProfile = profile
            print("✅ Profile loaded: \(name)")
        } else {
            print("⚠️  Failed to load profile: \(name)")
        }
    }

    private func loadDefaultProfile() {
        // For MVP, create a simple default profile with synthesized sounds
        print("📚 Loading default profile...")

        let profile = createDefaultSynthProfile()
        loadedProfiles["Default"] = profile
        currentProfile = profile

        print("✅ Default profile loaded")
    }

    // MARK: - Profile Creation

    private func createProfile(named name: String) -> SoundProfile? {
        // Create synthesized profile based on name
        switch name {
        case "Cherry MX Blue":
            return createCherryMXBlueProfile()
        case "Cherry MX Brown":
            return createCherryMXBrownProfile()
        case "Cherry MX Red":
            return createCherryMXRedProfile()
        case "Gateron Milky Yellow":
            return createGateronYellowProfile()
        case "NovelKeys Cream":
            return createNovelKeysCreamProfile()
        case "Default":
            return createDefaultSynthProfile()
        default:
            return createDefaultSynthProfile()
        }
    }

    func getAvailableProfiles() -> [String] {
        return [
            "Default",
            "Cherry MX Blue",
            "Cherry MX Brown",
            "Cherry MX Red",
            "Gateron Milky Yellow",
            "NovelKeys Cream"
        ]
    }

    private func createDefaultSynthProfile() -> SoundProfile {
        var keyDownSounds: [Int: AVAudioPCMBuffer] = [:]
        var keyUpSounds: [Int: AVAudioPCMBuffer] = [:]

        // Create a simple click sound buffer for all keys
        if let downBuffer = createClickSound(frequency: 800, duration: 0.05),
           let upBuffer = createClickSound(frequency: 600, duration: 0.03) {

            // Map all common key codes (0-127) to the same sound
            for keyCode in 0...127 {
                keyDownSounds[keyCode] = downBuffer
                keyUpSounds[keyCode] = upBuffer
            }
        }

        return SoundProfile(
            name: "Default",
            keyDownSounds: keyDownSounds,
            keyUpSounds: keyUpSounds
        )
    }

    // MARK: - Profile Creators

    private func createCherryMXBlueProfile() -> SoundProfile {
        // Clicky switch - High pitched click with sharp attack
        return createSynthProfile(
            name: "Cherry MX Blue",
            downFreq: 2500, downDuration: 0.04, downAmplitude: 0.35,
            upFreq: 1800, upDuration: 0.025, upAmplitude: 0.25,
            clickiness: 0.8
        )
    }

    private func createCherryMXBrownProfile() -> SoundProfile {
        // Tactile switch - Medium pitched bump
        return createSynthProfile(
            name: "Cherry MX Brown",
            downFreq: 1200, downDuration: 0.035, downAmplitude: 0.25,
            upFreq: 900, upDuration: 0.02, upAmplitude: 0.18,
            clickiness: 0.3
        )
    }

    private func createCherryMXRedProfile() -> SoundProfile {
        // Linear switch - Smooth, lower pitched
        return createSynthProfile(
            name: "Cherry MX Red",
            downFreq: 800, downDuration: 0.03, downAmplitude: 0.22,
            upFreq: 600, upDuration: 0.02, upAmplitude: 0.15,
            clickiness: 0.1
        )
    }

    private func createGateronYellowProfile() -> SoundProfile {
        // Deep, smooth linear
        return createSynthProfile(
            name: "Gateron Milky Yellow",
            downFreq: 700, downDuration: 0.035, downAmplitude: 0.28,
            upFreq: 500, upDuration: 0.025, upAmplitude: 0.18,
            clickiness: 0.15
        )
    }

    private func createNovelKeysCreamProfile() -> SoundProfile {
        // Creamy, bass-heavy sound
        return createSynthProfile(
            name: "NovelKeys Cream",
            downFreq: 600, downDuration: 0.04, downAmplitude: 0.3,
            upFreq: 450, upDuration: 0.03, upAmplitude: 0.2,
            clickiness: 0.05
        )
    }

    private func createSynthProfile(
        name: String,
        downFreq: Float, downDuration: Float, downAmplitude: Float,
        upFreq: Float, upDuration: Float, upAmplitude: Float,
        clickiness: Float
    ) -> SoundProfile {
        var keyDownSounds: [Int: AVAudioPCMBuffer] = [:]
        var keyUpSounds: [Int: AVAudioPCMBuffer] = [:]

        // Create sounds with specific characteristics
        if let downBuffer = createMechanicalSound(
            frequency: downFreq,
            duration: downDuration,
            amplitude: downAmplitude,
            clickiness: clickiness
        ),
           let upBuffer = createMechanicalSound(
            frequency: upFreq,
            duration: upDuration,
            amplitude: upAmplitude,
            clickiness: clickiness * 0.5
        ) {
            // Map all common key codes (0-127) to the same sound
            for keyCode in 0...127 {
                keyDownSounds[keyCode] = downBuffer
                keyUpSounds[keyCode] = upBuffer
            }
        }

        return SoundProfile(
            name: name,
            keyDownSounds: keyDownSounds,
            keyUpSounds: keyUpSounds
        )
    }

    // MARK: - Sound Synthesis

    private func createClickSound(frequency: Float, duration: Float) -> AVAudioPCMBuffer? {
        return createMechanicalSound(frequency: frequency, duration: duration, amplitude: 0.3, clickiness: 0.5)
    }

    private func createMechanicalSound(
        frequency: Float,
        duration: Float,
        amplitude: Float,
        clickiness: Float
    ) -> AVAudioPCMBuffer? {
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * Double(duration))

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        ) else {
            return nil
        }

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else {
            return nil
        }

        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData else {
            return nil
        }

        let leftChannel = channelData[0]
        let rightChannel = channelData[1]

        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / Float(sampleRate)
            let normalizedTime = time / duration

            // Exponential decay envelope for realistic sound
            let envelope = amplitude * exp(-5.0 * normalizedTime)

            // Base frequency sine wave
            var value = envelope * sin(2.0 * .pi * frequency * time)

            // Add harmonics for richness
            value += envelope * 0.3 * sin(2.0 * .pi * frequency * 2.0 * time)
            value += envelope * 0.15 * sin(2.0 * .pi * frequency * 3.0 * time)

            // Add click transient at the beginning for clicky switches
            if clickiness > 0 && normalizedTime < 0.1 {
                let clickEnvelope = clickiness * (1.0 - normalizedTime / 0.1)
                let noise = Float.random(in: -1...1) * clickEnvelope * 0.2
                value += noise
            }

            leftChannel[frame] = value
            rightChannel[frame] = value
        }

        return buffer
    }
}

// MARK: - Sound Profile Model

struct SoundProfile {
    let name: String
    let keyDownSounds: [Int: AVAudioPCMBuffer]
    let keyUpSounds: [Int: AVAudioPCMBuffer]
}

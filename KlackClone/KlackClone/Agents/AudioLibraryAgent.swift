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
        // Try to load from bundle
        // For now, return synthesized profile
        return createDefaultSynthProfile()
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

    // MARK: - Sound Synthesis

    private func createClickSound(frequency: Float, duration: Float) -> AVAudioPCMBuffer? {
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

        // Generate simple sine wave click
        guard let channelData = buffer.floatChannelData else {
            return nil
        }

        let leftChannel = channelData[0]
        let rightChannel = channelData[1]

        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / Float(sampleRate)
            let amplitude = Float(0.3) * (1.0 - time / duration) // Decay envelope

            let value = amplitude * sin(2.0 * .pi * frequency * time)

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

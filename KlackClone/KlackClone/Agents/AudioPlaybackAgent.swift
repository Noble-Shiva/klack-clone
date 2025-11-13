//
//  AudioPlaybackAgent.swift
//  KlackClone
//
//  Ultra-low latency audio playback for keyboard sounds
//

import AVFoundation
import Cocoa

class AudioPlaybackAgent {

    // MARK: - Properties

    private let audioEngine: AVAudioEngine
    private let mixer: AVAudioMixerNode

    private let audioLibrary: AudioLibraryAgent
    private let randomization: RandomizationAgent
    private let settings: SettingsAgent

    private var playerNodes: [AVAudioPlayerNode] = []
    private let maxConcurrentSounds = 20 // Maximum simultaneous sounds

    // MARK: - Initialization

    init(audioLibrary: AudioLibraryAgent, randomization: RandomizationAgent, settings: SettingsAgent) {
        self.audioLibrary = audioLibrary
        self.randomization = randomization
        self.settings = settings

        // Initialize audio engine
        self.audioEngine = AVAudioEngine()
        self.mixer = audioEngine.mainMixerNode

        print("🎧 AudioPlaybackAgent initialized")

        setupAudioEngine()
    }

    deinit {
        stop()
    }

    // MARK: - Setup

    private func setupAudioEngine() {
        // Configure for low latency
        do {
            // Create player nodes pool
            for _ in 0..<maxConcurrentSounds {
                let playerNode = AVAudioPlayerNode()
                audioEngine.attach(playerNode)
                audioEngine.connect(playerNode, to: mixer, format: nil)
                playerNodes.append(playerNode)
            }

            // Set output volume
            mixer.outputVolume = Float(settings.volume) / 100.0

            // Start the engine
            try audioEngine.start()

            print("✅ Audio engine started with \(maxConcurrentSounds) player nodes")

        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }

    // MARK: - Playback Methods

    func playKeyDownSound(for keyCode: Int) {
        guard let buffer = audioLibrary.getKeyDownSound(for: keyCode) else {
            // No sound for this key, silent key
            return
        }

        playSound(buffer: buffer)
    }

    func playKeyUpSound(for keyCode: Int) {
        guard let buffer = audioLibrary.getKeyUpSound(for: keyCode) else {
            // No sound for this key, silent key
            return
        }

        playSound(buffer: buffer)
    }

    private func playSound(buffer: AVAudioPCMBuffer) {
        // Find available player node
        guard let playerNode = getAvailablePlayerNode() else {
            print("⚠️  No available player nodes")
            return
        }

        // Get pitch variation
        let pitchShift = randomization.getPitchVariation()

        // Schedule buffer
        playerNode.scheduleBuffer(buffer) {
            // Buffer finished playing
        }

        // Apply pitch shift if needed
        if abs(pitchShift) > 0.001 {
            // Note: For MVP, we skip pitch shifting to reduce complexity
            // Will add AVAudioUnitTimePitch in Phase 3
        }

        // Start playback if not already playing
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    private func getAvailablePlayerNode() -> AVAudioPlayerNode? {
        // Find first non-playing node
        for node in playerNodes {
            if !node.isPlaying {
                return node
            }
        }

        // All nodes busy, return first one anyway (will interrupt)
        return playerNodes.first
    }

    // MARK: - Volume Control

    func setVolume(_ volume: Float) {
        mixer.outputVolume = volume / 100.0
    }

    // MARK: - Control

    func stop() {
        audioEngine.stop()
        print("🎧 Audio engine stopped")
    }
}

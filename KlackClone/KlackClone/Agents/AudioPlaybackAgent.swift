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
    private var pitchNodes: [AVAudioUnitTimePitch] = []
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
            // Create player nodes pool with pitch shifters
            for _ in 0..<maxConcurrentSounds {
                let playerNode = AVAudioPlayerNode()
                let pitchNode = AVAudioUnitTimePitch()

                audioEngine.attach(playerNode)
                audioEngine.attach(pitchNode)

                // Connect: PlayerNode -> PitchNode -> Mixer
                audioEngine.connect(playerNode, to: pitchNode, format: nil)
                audioEngine.connect(pitchNode, to: mixer, format: nil)

                playerNodes.append(playerNode)
                pitchNodes.append(pitchNode)
            }

            // Set output volume
            mixer.outputVolume = Float(settings.volume) / 100.0

            // Start the engine
            try audioEngine.start()

            print("✅ Audio engine started with \(maxConcurrentSounds) player nodes + pitch shifters")

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
        guard let index = getAvailablePlayerNodeIndex() else {
            print("⚠️  No available player nodes")
            return
        }

        let playerNode = playerNodes[index]
        let pitchNode = pitchNodes[index]

        // Get pitch variation (returns value like 0.95 to 1.05)
        let pitchVariation = randomization.getPitchVariation()

        // Convert to cents for AVAudioUnitTimePitch
        // 1 semitone = 100 cents
        // 5% variation = approximately ±86 cents
        let pitchCents = (pitchVariation - 1.0) * 1200.0 // Convert ratio to cents

        // Apply pitch shift
        pitchNode.pitch = pitchCents

        // Schedule buffer
        playerNode.scheduleBuffer(buffer) {
            // Buffer finished playing
        }

        // Start playback if not already playing
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    private func getAvailablePlayerNodeIndex() -> Int? {
        // Find first non-playing node
        for (index, node) in playerNodes.enumerated() {
            if !node.isPlaying {
                return index
            }
        }

        // All nodes busy, return first one anyway (will interrupt)
        return 0
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

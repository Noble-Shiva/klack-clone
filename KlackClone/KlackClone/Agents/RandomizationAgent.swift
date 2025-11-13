//
//  RandomizationAgent.swift
//  KlackClone
//
//  Provides organic sound variations through pitch randomization
//

import Foundation

class RandomizationAgent {

    // MARK: - Properties

    private let pitchVariationRange: Float = 0.05 // ±5%

    // MARK: - Initialization

    init() {
        print("🎲 RandomizationAgent initialized")
    }

    // MARK: - Randomization Methods

    /// Get a random pitch variation between 0.95 and 1.05 (±5%)
    func getPitchVariation() -> Float {
        let variation = Float.random(in: -pitchVariationRange...pitchVariationRange)
        return 1.0 + variation
    }

    /// Get a random sample index if multiple samples are available
    func getRandomSampleIndex(count: Int) -> Int {
        guard count > 0 else { return 0 }
        return Int.random(in: 0..<count)
    }
}

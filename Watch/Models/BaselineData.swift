//
//  BaselineData.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import Foundation

struct BaselineData {
    // MARK: Averages
    let avgHeartRate: Double
    let avgWalkingSpeed: Double
    let avgWalkingAsymmetry: Double
    let avgDoubleSupportTime: Double

    // MARK: Standard Deviations
    let heartRateStdDev: Double
    let walkingSpeedStdDev: Double
    let walkingAsymmetryStdDev: Double
    let doubleSupportTimeStdDev: Double

    /// true kalo data cukup buat baseline yang reliable
    var isEstablished: Bool

    // MARK: Factory
    static func make(
        heartRateSamples: [Double],
        historicalGaitSpeed: Double?,
        historicalGaitAsymmetry: Double?,
        historicalGaitDoubleSupport: Double?,
        minHeartRateSamples: Int = 10
    ) -> BaselineData? {
        guard heartRateSamples.count >= minHeartRateSamples else { return nil }

        return BaselineData(
            avgHeartRate:            Self.mean(heartRateSamples),
            avgWalkingSpeed:         historicalGaitSpeed ?? 0,
            avgWalkingAsymmetry:     historicalGaitAsymmetry ?? 0,
            avgDoubleSupportTime:    historicalGaitDoubleSupport ?? 0,
            heartRateStdDev:         Self.stdDev(heartRateSamples),
            // Std dev gait tidak tersedia dari rata-rata historis saja.
            walkingSpeedStdDev:      0,
            walkingAsymmetryStdDev:  0,
            doubleSupportTimeStdDev: 0,
            isEstablished: true
        )
    }

    // MARK: Math Helpers

    private static func mean(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func stdDev(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let avg = mean(values)
        let variance = values.reduce(0) { $0 + ($1 - avg) * ($1 - avg) } / Double(values.count - 1)
        return sqrt(variance)
    }
}

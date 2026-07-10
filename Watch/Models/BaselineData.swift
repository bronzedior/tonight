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

    let avgWalkingSpeed: Double?
    let avgWalkingAsymmetry: Double?
    let avgDoubleSupportTime: Double?

    // MARK: Standard Deviations
    let heartRateStdDev: Double

    /// true kalo data cukup buat baseline yang reliable
    var isEstablished: Bool

    // MARK: Factory
    static func make(
        heartRateSamples: [Double],
        historicalGaitSpeed: Double?,
        historicalGaitAsymmetry: Double?,
        historicalGaitDoubleSupport: Double?,
        minHeartRateSamples: Int = 1
    ) -> BaselineData? {
        guard heartRateSamples.count >= max(1, minHeartRateSamples) else { return nil }

        return BaselineData(
            avgHeartRate:            Self.mean(heartRateSamples),
            avgWalkingSpeed:         historicalGaitSpeed,
            avgWalkingAsymmetry:     historicalGaitAsymmetry,
            avgDoubleSupportTime:    historicalGaitDoubleSupport,
            heartRateStdDev:         Self.stdDev(heartRateSamples),
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

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

    /// Menghitung BaselineData dari kumpulan sampel.
    /// Membutuhkan minimal `minHeartRateSamples` HR dan `minWalkingSamples` walking data.
    static func calculate(
        from samples: [HealthMetricSample],
        minHeartRateSamples: Int = 10,
        minWalkingSamples: Int = 2
    ) -> BaselineData? {
        let hrValues = samples.map { $0.heartRate }
        guard hrValues.count >= minHeartRateSamples else { return nil }

        let walkingSpeeds      = samples.compactMap { $0.walkingSpeed }
        let walkingAsymmetries = samples.compactMap { $0.walkingAsymmetry }
        let doubleSupportTimes = samples.compactMap { $0.doubleSupportTime }

        // Walking data mungkin belum tersedia jika user diam.
        // Tetap buat baseline tapi tandai walking dengan 0 jika kosong.
        let hasEnoughWalking = walkingSpeeds.count >= minWalkingSamples

        return BaselineData(
            avgHeartRate:            Self.mean(hrValues),
            avgWalkingSpeed:         hasEnoughWalking ? Self.mean(walkingSpeeds)      : 0,
            avgWalkingAsymmetry:     hasEnoughWalking ? Self.mean(walkingAsymmetries)  : 0,
            avgDoubleSupportTime:    hasEnoughWalking ? Self.mean(doubleSupportTimes)  : 0,
            heartRateStdDev:         Self.stdDev(hrValues),
            walkingSpeedStdDev:      hasEnoughWalking ? Self.stdDev(walkingSpeeds)      : 0,
            walkingAsymmetryStdDev:  hasEnoughWalking ? Self.stdDev(walkingAsymmetries) : 0,
            doubleSupportTimeStdDev: hasEnoughWalking ? Self.stdDev(doubleSupportTimes) : 0,
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

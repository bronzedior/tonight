//
//  IntoxicationResult.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import Foundation

struct IntoxicationResult {
    let riskScore: Int               // 0-100, makin tinggi makin mabuk
    let soberScore: Int              // 0-100, makin tinggi makin sober (100 - riskScore)
    let level: SoberLevel            // SOBER / OK / SEMI-DRUNK / DRUNK

    let heartRateDeviation: Double
    let walkingSpeedDeviation: Double
    let walkingAsymmetryDeviation: Double
    let doubleSupportTimeDeviation: Double

    let heartRateNormalized: Double
    let walkingSpeedNormalized: Double
    let walkingAsymmetryNormalized: Double
    let doubleSupportTimeNormalized: Double

    let gaitMetricsUsed: Int

    var gaitDeviation: Double {
        guard gaitMetricsUsed > 0 else { return 0 }
        let sum = walkingSpeedNormalized + walkingAsymmetryNormalized + doubleSupportTimeNormalized
        return sum / Double(gaitMetricsUsed) * 100
    }
}

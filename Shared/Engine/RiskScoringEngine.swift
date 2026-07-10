
//  Created by Yuki Damanik on 02/07/26.
//

import Foundation

enum ScoringMode {
    case stationary
    case walking
}

struct RiskScoringEngine {

    // MARK: - Weights
    private static let heartRateWeight:        Double = 0.30
    private static let walkingSpeedWeight:      Double = 0.20
    private static let walkingAsymmetryWeight:  Double = 0.30
    private static let doubleSupportTimeWeight: Double = 0.20

    // MARK: - Normalization Max Thresholds (%)
    private static let hrMaxPercent: Double = 40.0
    private static let speedMaxPercent: Double = 35.0
    private static let asymmetryMaxPercent: Double = 300.0
    private static let dstMaxPercent: Double = 60.0

    // MARK: - Baseline Floors
    private static let minWalkingSpeedBaseline:   Double = 0.5   // m/s
    private static let minAsymmetryBaseline:      Double = 1.0   // %
    private static let minDoubleSupportBaseline:  Double = 5.0   // %

    // MARK: - Calculate
    static func calculateSoberScore(
        currentHR: Double,
        currentWalkingSpeed: Double?,
        currentAsymmetry: Double?,
        currentDST: Double?,
        baseline: BaselineData,
        mode: ScoringMode
    ) -> IntoxicationResult {

        // --- Step 1: Hitung Deviation (%) ---
        // HR: naik = positif (indikator mabuk)
        let hrDeviation: Double = baseline.avgHeartRate > 0
            ? ((currentHR - baseline.avgHeartRate) / baseline.avgHeartRate) * 100
            : 0

        // Walking Speed: turun = positif (indikator mabuk, jadi kita ambil absolute drop)
        let speedDeviation: Double = {
            guard let speed = currentWalkingSpeed,
                  let base = baseline.avgWalkingSpeed else { return 0 }
            return ((base - speed) / max(base, minWalkingSpeedBaseline)) * 100
        }()

        // Walking Asymmetry: naik = positif (indikator mabuk)
        let asymmetryDeviation: Double = {
            guard let asymmetry = currentAsymmetry,
                  let base = baseline.avgWalkingAsymmetry else { return 0 }
            return ((asymmetry - base) / max(base, minAsymmetryBaseline)) * 100
        }()

        // Double Support Time: naik = positif (indikator mabuk)
        let dstDeviation: Double = {
            guard let dst = currentDST,
                  let base = baseline.avgDoubleSupportTime else { return 0 }
            return ((dst - base) / max(base, minDoubleSupportBaseline)) * 100
        }()

        // --- Step 2: Normalisasi (0-1) ---
        // Clamp ke 0 minimum (jika membaik dari baseline, tidak menambah risk)
        let hrNormalized        = min(1.0, max(0, hrDeviation) / hrMaxPercent)
        let speedNormalized     = min(1.0, max(0, speedDeviation) / speedMaxPercent)
        let asymmetryNormalized = min(1.0, max(0, asymmetryDeviation) / asymmetryMaxPercent)
        let dstNormalized       = min(1.0, max(0, dstDeviation) / dstMaxPercent)

        // --- Step 3: Hitung Risk Score ---
        // Risk = sum(normalized × weight) × 100
        var weightedSum: Double = 0
        var totalWeight: Double = 0
        var gaitMetricsUsed = 0

        // HR selalu tersedia (satu-satunya sinyal di mode stationary)
        weightedSum += hrNormalized * heartRateWeight
        totalWeight += heartRateWeight

        // Gait metrics hanya diperhitungkan saat user bergerak (mode .walking)
        // DAN baseline + data current tersedia. Saat .stationary gait diabaikan.
        if mode == .walking {
            if currentWalkingSpeed != nil, baseline.avgWalkingSpeed != nil {
                weightedSum += speedNormalized * walkingSpeedWeight
                totalWeight += walkingSpeedWeight
                gaitMetricsUsed += 1
            }

            if currentAsymmetry != nil, baseline.avgWalkingAsymmetry != nil {
                weightedSum += asymmetryNormalized * walkingAsymmetryWeight
                totalWeight += walkingAsymmetryWeight
                gaitMetricsUsed += 1
            }

            if currentDST != nil, baseline.avgDoubleSupportTime != nil {
                weightedSum += dstNormalized * doubleSupportTimeWeight
                totalWeight += doubleSupportTimeWeight
                gaitMetricsUsed += 1
            }
        }

        // Normalize jika tidak semua metrik tersedia
        let normalizedRisk = totalWeight > 0 ? weightedSum / totalWeight : 0
        let riskScore = min(100, max(0, Int((normalizedRisk * 100).rounded())))
        let soberScore = 100 - riskScore

        return IntoxicationResult(
            riskScore: riskScore,
            soberScore: soberScore,
            level: SoberLevel.from(score: soberScore),
            heartRateDeviation: hrDeviation,
            walkingSpeedDeviation: speedDeviation,
            walkingAsymmetryDeviation: asymmetryDeviation,
            doubleSupportTimeDeviation: dstDeviation,
            heartRateNormalized: hrNormalized,
            walkingSpeedNormalized: speedNormalized,
            walkingAsymmetryNormalized: asymmetryNormalized,
            doubleSupportTimeNormalized: dstNormalized,
            gaitMetricsUsed: gaitMetricsUsed
        )
    }
}

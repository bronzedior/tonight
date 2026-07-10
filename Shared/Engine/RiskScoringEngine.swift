
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
        let speedDeviation: Double
        if let speed = currentWalkingSpeed, baseline.avgWalkingSpeed > 0 {
            speedDeviation = ((baseline.avgWalkingSpeed - speed) / baseline.avgWalkingSpeed) * 100
        } else {
            speedDeviation = 0
        }

        // Walking Asymmetry: naik = positif (indikator mabuk)
        let asymmetryDeviation: Double
        if let asymmetry = currentAsymmetry, baseline.avgWalkingAsymmetry > 0 {
            asymmetryDeviation = ((asymmetry - baseline.avgWalkingAsymmetry) / baseline.avgWalkingAsymmetry) * 100
        } else {
            asymmetryDeviation = 0
        }

        // Double Support Time: naik = positif (indikator mabuk)
        let dstDeviation: Double
        if let dst = currentDST, baseline.avgDoubleSupportTime > 0 {
            dstDeviation = ((dst - baseline.avgDoubleSupportTime) / baseline.avgDoubleSupportTime) * 100
        } else {
            dstDeviation = 0
        }

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

        // HR selalu tersedia (satu-satunya sinyal di mode stationary)
        weightedSum += hrNormalized * heartRateWeight
        totalWeight += heartRateWeight

        // Gait metrics hanya diperhitungkan saat user bergerak (mode .walking)
        // DAN baseline + data current tersedia. Saat .stationary gait diabaikan.
        if mode == .walking {
            if currentWalkingSpeed != nil && baseline.avgWalkingSpeed > 0 {
                weightedSum += speedNormalized * walkingSpeedWeight
                totalWeight += walkingSpeedWeight
            }

            if currentAsymmetry != nil && baseline.avgWalkingAsymmetry > 0 {
                weightedSum += asymmetryNormalized * walkingAsymmetryWeight
                totalWeight += walkingAsymmetryWeight
            }

            if currentDST != nil && baseline.avgDoubleSupportTime > 0 {
                weightedSum += dstNormalized * doubleSupportTimeWeight
                totalWeight += doubleSupportTimeWeight
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
            doubleSupportTimeNormalized: dstNormalized
        )
    }
}

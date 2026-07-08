//
//  RiskScoringEngine.swift
//  tonight
//
//  Created by Yuki Damanik on 02/07/26.
//

import Foundation

/// Engine untuk menghitung risk score berdasarkan deviasi data saat ini dari baseline.
///
/// Langkah perhitungan:
/// 1. Hitung % deviation dari baseline untuk setiap metrik
/// 2. Normalisasi deviation ke 0-1 dengan membagi max threshold
/// 3. Kalikan normalized score dengan bobot masing-masing
/// 4. Risk Score = sum(normalized × weight) × 100
///
/// Bobot:
/// - Heart Rate: 0.30
/// - Walking Speed: 0.30
/// - Walking Asymmetry: 0.20
/// - Double Support Time: 0.20
///
/// Max Threshold (normalisasi):
/// - Heart Rate: 40%
/// - Walking Speed: 35%
/// - Walking Asymmetry: 300%
/// - Double Support Time: 60%
struct RiskScoringEngine {

    // MARK: - Weights

    private static let heartRateWeight:        Double = 0.30
    private static let walkingSpeedWeight:      Double = 0.30
    private static let walkingAsymmetryWeight:  Double = 0.20
    private static let doubleSupportTimeWeight: Double = 0.20

    // MARK: - Normalization Max Thresholds (%)

    /// HR naik lebih dari 40% dari baseline = normalized 1.0
    private static let hrMaxPercent: Double = 40.0
    /// Walking speed turun lebih dari 35% dari baseline = normalized 1.0
    private static let speedMaxPercent: Double = 35.0
    /// Walking asymmetry naik lebih dari 300% dari baseline = normalized 1.0
    private static let asymmetryMaxPercent: Double = 300.0
    /// Double support naik lebih dari 60% dari baseline = normalized 1.0
    private static let dstMaxPercent: Double = 60.0

    // MARK: - Calculate

    /// Menghitung IntoxicationResult berdasarkan perbandingan data saat ini vs baseline.
    ///
    /// Contoh perhitungan:
    /// ```
    /// Baseline: HR=70, Speed=1.35, Asym=2%, DST=20%
    /// Current:  HR=91, Speed=1.08, Asym=6%, DST=28%
    ///
    /// Deviation: HR=+30%, Speed=-20%, Asym=+200%, DST=+40%
    /// Normalized: HR=30/40=0.75, Speed=20/35=0.57, Asym=200/300=0.67, DST=40/60=0.67
    /// Risk = (0.75×0.30) + (0.57×0.30) + (0.67×0.20) + (0.67×0.20) = 0.664
    /// Risk Score = 0.664 × 100 = 66 (Moderate Risk)
    /// ```
    static func calculateSoberScore(
        currentHR: Double,
        currentWalkingSpeed: Double?,
        currentAsymmetry: Double?,
        currentDST: Double?,
        baseline: BaselineData
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

        // HR selalu tersedia
        weightedSum += hrNormalized * heartRateWeight
        totalWeight += heartRateWeight

        // Walking metrics hanya dihitung jika baseline & current tersedia
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

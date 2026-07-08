//
//  SessionViewModel.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI
import Combine

/// Fase baseline saat monitoring dimulai.
enum BaselinePhase {
    case idle           // Belum mulai
    case collecting     // Sedang mengumpulkan data baseline (5 menit)
    case established    // Baseline sudah siap, deteksi berjalan
}

/// ViewModel utama untuk sesi monitoring di watchOS.
/// Menggantikan DummyDataProvider dengan data real dari HealthKit.
///
/// Flow:
/// 1. User tap Start → `startSession()` → HealthKit authorization
/// 2. Baseline phase (5 menit): kumpulkan data, hitung rata-rata & std dev
/// 3. Detection phase: bandingkan data baru vs baseline → hitung sober score
class SessionViewModel: ObservableObject {

    // MARK: - Published Properties (untuk Views)

    /// Apakah sesi monitoring sedang berjalan
    @Published var isMonitoring = false

    /// Fase baseline saat ini
    @Published var baselinePhase: BaselinePhase = .idle

    /// Progress pengumpulan baseline (0.0 - 1.0)
    @Published var baselineProgress: Double = 0.0

    /// Sober score saat ini (0-100)
    @Published var soberScore: Int = 100

    /// Level sober saat ini
    @Published var currentLevel: SoberLevel = .sober

    /// Heart rate terakhir yang diterima
    @Published var latestHeartRate: Double = 0

    /// Data heart rate untuk chart (per menit: low-high range)
    @Published var heartRateReadings: [HeartRateReading] = []

    /// Data gait untuk chart
    @Published var gaitReadings: [GaitReading] = []

    /// Tanggal sesi dimulai
    @Published var sessionDate: Date = Date()

    /// Walking metrics terakhir
    @Published var latestWalkingSpeed: Double?
    @Published var latestWalkingAsymmetry: Double?
    @Published var latestDoubleSupportTime: Double?

    // MARK: - Internal State

    /// Service untuk koneksi ke HealthKit
    private let healthService = HealthKitService()

    /// Sampel yang dikumpulkan selama fase baseline
    private var baselineSamples: [HealthMetricSample] = []

    /// Baseline yang sudah dihitung
    private var baseline: BaselineData?

    /// Waktu mulai sesi
    private var sessionStartDate: Date?

    /// Durasi baseline dalam detik (5 menit)
    private let baselineDuration: TimeInterval = 5 * 60

    /// Timer untuk update progress baseline
    private var baselineTimer: Timer?

    /// Semua HR readings dalam menit yang sama, untuk aggregasi ke HeartRateReading
    private var minuteHeartRates: [Int: [Double]] = [:]

    /// Semua HR readings setelah baseline (untuk sliding window)
    private var recentHeartRates: [Double] = []

    // MARK: - Session Control

    /// Mulai sesi monitoring baru.
    func startSession() {
        healthService.requestAuthorization { [weak self] authorized in
            guard let self = self, authorized else {
                print("[SessionViewModel] HealthKit not authorized")
                return
            }
            self.beginMonitoring()
        }
    }

    /// Stop sesi monitoring.
    func stopSession() {
        healthService.stopMonitoring()
        baselineTimer?.invalidate()
        baselineTimer = nil
        isMonitoring = false
        baselinePhase = .idle
        baselineProgress = 0
        baselineSamples = []
        baseline = nil
        minuteHeartRates = [:]
        recentHeartRates = []
        heartRateReadings = []
        gaitReadings = []
    }

    // MARK: - Private — Start Monitoring

    private func beginMonitoring() {
        sessionStartDate = Date()
        sessionDate = Date()
        isMonitoring = true
        baselinePhase = .collecting
        baselineProgress = 0
        soberScore = 100
        currentLevel = .sober

        // Setup callbacks dari HealthKitService
        healthService.onNewHeartRate = { [weak self] bpm, timestamp in
            self?.handleNewHeartRate(bpm: bpm, timestamp: timestamp)
        }

        healthService.onNewWalkingData = { [weak self] speed, asymmetry, dst in
            self?.handleNewWalkingData(speed: speed, asymmetry: asymmetry, dst: dst)
        }

        // Start HealthKit monitoring
        healthService.startMonitoring()

        // Start baseline progress timer (update setiap detik)
        baselineTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateBaselineProgress()
        }
    }

    // MARK: - Handle Heart Rate Data

    private func handleNewHeartRate(bpm: Double, timestamp: Date) {
        latestHeartRate = bpm

        guard let startDate = sessionStartDate else { return }
        let minuteOffset = Int(timestamp.timeIntervalSince(startDate) / 60)

        // Simpan ke minute bucket untuk chart
        if minuteHeartRates[minuteOffset] == nil {
            minuteHeartRates[minuteOffset] = []
        }
        minuteHeartRates[minuteOffset]?.append(bpm)

        // Update chart readings
        updateHeartRateChart()

        switch baselinePhase {
        case .collecting:
            // Tambahkan ke baseline samples
            let sample = HealthMetricSample(
                timestamp: timestamp,
                heartRate: bpm,
                walkingSpeed: latestWalkingSpeed,
                walkingAsymmetry: latestWalkingAsymmetry,
                doubleSupportTime: latestDoubleSupportTime
            )
            baselineSamples.append(sample)

        case .established:
            // Hitung sober score berdasarkan deviasi dari baseline
            guard let baseline = baseline else { return }

            recentHeartRates.append(bpm)
            // Gunakan sliding window 10 HR terbaru untuk smoothing
            if recentHeartRates.count > 10 {
                recentHeartRates.removeFirst()
            }
            let avgRecentHR = recentHeartRates.reduce(0, +) / Double(recentHeartRates.count)

            let result = RiskScoringEngine.calculateSoberScore(
                currentHR: avgRecentHR,
                currentWalkingSpeed: latestWalkingSpeed,
                currentAsymmetry: latestWalkingAsymmetry,
                currentDST: latestDoubleSupportTime,
                baseline: baseline
            )

            withAnimation(.easeInOut(duration: 0.5)) {
                soberScore = result.soberScore
                currentLevel = result.level
            }

            // Update gait reading jika ada data walking baru
            updateGaitReading(minuteOffset: minuteOffset, result: result)

        case .idle:
            break
        }
    }

    // MARK: - Handle Walking Data

    private func handleNewWalkingData(speed: Double?, asymmetry: Double?, dst: Double?) {
        latestWalkingSpeed = speed
        latestWalkingAsymmetry = asymmetry
        latestDoubleSupportTime = dst
    }

    // MARK: - Baseline Progress

    private func updateBaselineProgress() {
        guard let startDate = sessionStartDate, baselinePhase == .collecting else { return }

        let elapsed = Date().timeIntervalSince(startDate)
        baselineProgress = min(1.0, elapsed / baselineDuration)

        // Check apakah baseline sudah selesai
        if elapsed >= baselineDuration {
            finalizeBaseline()
        }
    }

    private func finalizeBaseline() {
        baselineTimer?.invalidate()
        baselineTimer = nil

        // Hitung baseline dari sampel yang terkumpul
        if let calculatedBaseline = BaselineData.calculate(from: baselineSamples) {
            baseline = calculatedBaseline
            baselinePhase = .established
            baselineProgress = 1.0
            print("[SessionViewModel] Baseline established!")
            print("  - Avg HR: \(calculatedBaseline.avgHeartRate) BPM")
            print("  - Avg Walking Speed: \(calculatedBaseline.avgWalkingSpeed) m/s")
            print("  - Avg Asymmetry: \(calculatedBaseline.avgWalkingAsymmetry)%")
            print("  - Avg DST: \(calculatedBaseline.avgDoubleSupportTime)%")
        } else {
            // Tidak cukup data, tetap lanjutkan dengan data yang ada
            // Buat baseline minimal hanya dari HR
            let hrValues = baselineSamples.map { $0.heartRate }
            if !hrValues.isEmpty {
                let avg = hrValues.reduce(0, +) / Double(hrValues.count)
                let variance = hrValues.reduce(0) { $0 + ($1 - avg) * ($1 - avg) }
                    / max(1, Double(hrValues.count - 1))
                let stdDev = sqrt(variance)

                baseline = BaselineData(
                    avgHeartRate: avg,
                    avgWalkingSpeed: 0,
                    avgWalkingAsymmetry: 0,
                    avgDoubleSupportTime: 0,
                    heartRateStdDev: stdDev,
                    walkingSpeedStdDev: 0,
                    walkingAsymmetryStdDev: 0,
                    doubleSupportTimeStdDev: 0,
                    isEstablished: true
                )
                baselinePhase = .established
                baselineProgress = 1.0
                print("[SessionViewModel] Baseline established (HR only — no walking data)")
            } else {
                // Benar-benar tidak ada data, extend baseline 2 menit lagi
                print("[SessionViewModel] Not enough data, extending baseline...")
                baselineTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    self?.updateBaselineProgress()
                }
            }
        }
    }

    // MARK: - Chart Updates

    private func updateHeartRateChart() {
        heartRateReadings = minuteHeartRates.map { (minute, bpms) in
            HeartRateReading(
                minuteOffset: minute,
                bpmLow: Int(bpms.min() ?? 0),
                bpmHigh: Int(bpms.max() ?? 0)
            )
        }.sorted { $0.minuteOffset < $1.minuteOffset }
    }

    /// Track menit terakhir yang punya gait reading, hindari duplikat
    private var lastGaitMinute: Int = -1

    private func updateGaitReading(minuteOffset: Int, result: IntoxicationResult) {
        // Tambahkan gait reading per menit (bukan per HR sample)
        guard minuteOffset > lastGaitMinute else { return }
        guard latestWalkingSpeed != nil || latestWalkingAsymmetry != nil || latestDoubleSupportTime != nil else { return }

        lastGaitMinute = minuteOffset

        // Stability = 100 - gait deviation (semakin sedikit deviasi = semakin stabil)
        let stability = max(0, min(100, 100 - result.gaitDeviation))

        gaitReadings.append(
            GaitReading(minuteOffset: minuteOffset, stability: stability)
        )
    }
}

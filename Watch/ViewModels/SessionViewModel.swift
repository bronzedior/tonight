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

    /// Mode scoring saat ini (dari CoreMotion): stationary = HR-only, walking = HR + gait.
    @Published var scoringMode: ScoringMode = .stationary

    // MARK: - Internal State

    /// Service untuk koneksi ke HealthKit
    private let healthService = HealthKitService()

    /// Service untuk deteksi aktivitas (stationary vs walking) via CoreMotion
    private let motionService = MotionActivityService()

    /// Rata-rata gait historis (30 hari) dari HealthKit — baseline untuk gait metrics.
    private var historicalGaitSpeed: Double?
    private var historicalGaitAsymmetry: Double?
    private var historicalGaitDoubleSupport: Double?

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
        motionService.stop()
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
        scoringMode = .stationary
        historicalGaitSpeed = nil
        historicalGaitAsymmetry = nil
        historicalGaitDoubleSupport = nil
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

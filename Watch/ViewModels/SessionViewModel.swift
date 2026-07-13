//
//  SessionViewModel.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI
import Combine

enum BaselinePhase {
    case idle           // Belum mulai
    case collecting     // Sedang mengumpulkan data baseline
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

    /// Durasi kalibrasi baseline HR dalam detik.
    private let baselineDuration: TimeInterval = 5

    /// Minimal sampel HR sebelum baseline dianggap valid. Window kalibrasi cuma
    /// 5 detik, sementara HealthKit ngirim HR tiap ~5 detik — jadi 1 sampel.
    private let minBaselineHeartRateSamples = 1

    /// Timer untuk update progress baseline
    private var baselineTimer: Timer?

    /// Window kalibrasi habis tapi belum ada satu pun sampel HR yang masuk.
    /// Baseline di-establish begitu sampel HR pertama datang.
    private var awaitingBaselineHeartRate = false

    /// Semua HR readings dalam menit yang sama, untuk aggregasi ke HeartRateReading
    private var minuteHeartRates: [Int: [Double]] = [:]

    /// HR readings terakhir setelah baseline (sliding window, buat meredam noise)
    private var recentHeartRates: [Double] = []
    private let recentHeartRateWindow = 5

    /// Riwayat impairment (= 100 - soberScore) selama sesi, buat timeline yang
    /// dikirim ke iPhone saat sesi berakhir.
    private var impairmentSamples: [(date: Date, score: Double, level: SoberLevel)] = []

    /// Pengirim ringkasan sesi ke iPhone lewat WatchConnectivity.
    private let phoneSender = WatchSessionSender.shared

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
        if let transfer = buildSessionTransfer() {
            phoneSender.send(transfer)
        }

        healthService.stopMonitoring()
        healthService.onNewHeartRate = nil
        healthService.onNewWalkingData = nil
        motionService.stop()
        motionService.onModeChange = nil
        baselineTimer?.invalidate()
        baselineTimer = nil
        isMonitoring = false
        baselinePhase = .idle
        baselineProgress = 0
        baselineSamples = []
        baseline = nil
        awaitingBaselineHeartRate = false
        minuteHeartRates = [:]
        recentHeartRates = []
        impairmentSamples = []
        heartRateReadings = []
        gaitReadings = []
        scoringMode = .stationary
        sessionStartDate = nil
        latestHeartRate = 0
        latestWalkingSpeed = nil
        latestWalkingAsymmetry = nil
        latestDoubleSupportTime = nil
        historicalGaitSpeed = nil
        historicalGaitAsymmetry = nil
        historicalGaitDoubleSupport = nil
    }

    // MARK: - Private — Start Monitoring

    private func beginMonitoring() {
        let now = Date()
        sessionStartDate = now
        sessionDate = now
        isMonitoring = true
        baselinePhase = .collecting
        baselineProgress = 0
        soberScore = 100
        currentLevel = .sober
        baselineSamples = []
        baseline = nil
        awaitingBaselineHeartRate = false
        minuteHeartRates = [:]
        recentHeartRates = []
        impairmentSamples = []
        heartRateReadings = []
        gaitReadings = []

        // Setup callbacks dari HealthKitService
        healthService.onNewHeartRate = { [weak self] bpm, timestamp in
            self?.handleNewHeartRate(bpm: bpm, timestamp: timestamp)
        }

        healthService.onNewWalkingData = { [weak self] speed, asymmetry, dst in
            self?.handleNewWalkingData(speed: speed, asymmetry: asymmetry, dst: dst)
        }

        // CoreMotion nentuin mode: stationary = HR-only, walking = HR + gait.
        motionService.onModeChange = { [weak self] mode in
            self?.handleModeChange(mode)
        }

        // Baseline gait diambil dari rata-rata historis 30 hari di HealthKit,
        // bukan dari kalibrasi realtime (kalibrasi cuma ngukur HR).
        healthService.fetchGaitBaseline(days: 30) { [weak self] speed, asymmetry, dst in
            guard let self = self else { return }
            self.historicalGaitSpeed = speed
            self.historicalGaitAsymmetry = asymmetry
            self.historicalGaitDoubleSupport = dst

            // Query historis bisa selesai setelah baseline HR jadi. Rebuild supaya
            // gait ikut kepakai, bukan ke-skip selamanya.
            if self.baselinePhase == .established {
                self.establishBaseline()
            }
        }

        healthService.startMonitoring()
        motionService.start()
        startBaselineTimer()
    }

    // MARK: - Private — Baseline

    private func startBaselineTimer() {
        baselineTimer?.invalidate()
        let start = Date()

        baselineTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            let elapsed = Date().timeIntervalSince(start)
            self.baselineProgress = min(1.0, elapsed / self.baselineDuration)

            guard elapsed >= self.baselineDuration else { return }
            timer.invalidate()
            self.baselineTimer = nil
            self.finishBaselineCollection()
        }
    }

    private func finishBaselineCollection() {
        baselineProgress = 1.0

        // Window 5 detik bisa lewat sebelum sampel HR pertama sampai.
        // Kalau begitu, tunggu — jangan establish baseline tanpa data HR.
        if !establishBaseline() {
            awaitingBaselineHeartRate = true
        }
    }

    @discardableResult
    private func establishBaseline() -> Bool {
        guard let data = BaselineData.make(
            heartRateSamples: baselineSamples.map(\.heartRate),
            historicalGaitSpeed: historicalGaitSpeed,
            historicalGaitAsymmetry: historicalGaitAsymmetry,
            historicalGaitDoubleSupport: historicalGaitDoubleSupport,
            minHeartRateSamples: minBaselineHeartRateSamples
        ) else { return false }

        baseline = data
        awaitingBaselineHeartRate = false
        baselinePhase = .established
        recalculateScore()
        return true
    }

    // MARK: - Private — Data Handlers

    private func handleNewHeartRate(bpm: Double, timestamp: Date) {
        guard bpm > 0, baselinePhase != .idle else { return }

        latestHeartRate = bpm
        appendHeartRateReading(bpm: bpm, timestamp: timestamp)

        switch baselinePhase {
        case .collecting:
            baselineSamples.append(
                HealthMetricSample(
                    timestamp: timestamp,
                    heartRate: bpm,
                    walkingSpeed: nil,
                    walkingAsymmetry: nil,
                    doubleSupportTime: nil
                )
            )
            // Timer sudah habis, sampel pertama baru nyampe sekarang.
            if awaitingBaselineHeartRate {
                establishBaseline()
            }

        case .established:
            recentHeartRates.append(bpm)
            if recentHeartRates.count > recentHeartRateWindow {
                recentHeartRates.removeFirst(recentHeartRates.count - recentHeartRateWindow)
            }
            recalculateScore()

        case .idle:
            break
        }
    }

    private func handleNewWalkingData(speed: Double?, asymmetry: Double?, dst: Double?) {
        latestWalkingSpeed = speed
        latestWalkingAsymmetry = asymmetry
        latestDoubleSupportTime = dst

        guard baselinePhase == .established else { return }
        recalculateScore()
    }

    private func handleModeChange(_ mode: ScoringMode) {
        scoringMode = mode

        guard baselinePhase == .established else { return }
        recalculateScore()
    }

    // MARK: - Private — Scoring

    private func recalculateScore() {
        guard baselinePhase == .established, let baseline = baseline else { return }

        let currentHR = smoothedHeartRate
        guard currentHR > 0 else { return }

        // Saat stationary, gait sengaja dikirim nil biar engine skor murni dari HR.
        let isWalking = scoringMode == .walking

        let result = RiskScoringEngine.calculateSoberScore(
            currentHR: currentHR,
            currentWalkingSpeed: isWalking ? latestWalkingSpeed : nil,
            currentAsymmetry: isWalking ? latestWalkingAsymmetry : nil,
            currentDST: isWalking ? latestDoubleSupportTime : nil,
            baseline: baseline,
            mode: scoringMode
        )

        soberScore = result.soberScore
        currentLevel = result.level
        impairmentSamples.append((Date(), Double(result.riskScore), result.level))
        appendGaitReading(from: result)
    }

    /// Rata-rata beberapa HR terakhir — satu sampel mentah terlalu berisik buat skor.
    private var smoothedHeartRate: Double {
        guard !recentHeartRates.isEmpty else { return latestHeartRate }
        return recentHeartRates.reduce(0, +) / Double(recentHeartRates.count)
    }

    // MARK: - Private — Chart Aggregation

    private func appendHeartRateReading(bpm: Double, timestamp: Date) {
        guard let start = sessionStartDate else { return }

        let minute = max(0, Int(timestamp.timeIntervalSince(start) / 60))
        minuteHeartRates[minute, default: []].append(bpm)

        heartRateReadings = minuteHeartRates
            .sorted { $0.key < $1.key }
            .map { minute, values in
                HeartRateReading(
                    minuteOffset: minute,
                    bpmLow: Int((values.min() ?? 0).rounded()),
                    bpmHigh: Int((values.max() ?? 0).rounded())
                )
            }
    }

    private func appendGaitReading(from result: IntoxicationResult) {
        // Cuma plot titik gait kalau gait beneran ikut dihitung di skor.
        guard let start = sessionStartDate, result.gaitMetricsUsed > 0 else { return }

        let minute = max(0, Int(Date().timeIntervalSince(start) / 60))
        let stability = min(100, max(0, 100 - result.gaitDeviation))
        let reading = GaitReading(minuteOffset: minute, stability: stability)

        if let index = gaitReadings.firstIndex(where: { $0.minuteOffset == minute }) {
            gaitReadings[index] = reading
        } else {
            gaitReadings.append(reading)
        }
    }

    // MARK: - Private — Session Transfer (Watch → iPhone)

    private func buildSessionTransfer() -> SessionTransfer? {
        guard let start = sessionStartDate, !heartRateReadings.isEmpty else { return nil }
        let end = Date()

        // Heart rate: per-menit low/high → interval.
        let hrSamples: [SessionTransfer.HeartRateInterval] = heartRateReadings.map { reading in
            let segStart = start.addingTimeInterval(TimeInterval(reading.minuteOffset * 60))
            return SessionTransfer.HeartRateInterval(
                start: segStart,
                end: segStart.addingTimeInterval(60),
                minBPM: Double(reading.bpmLow),
                maxBPM: Double(reading.bpmHigh)
            )
        }

        // Body-gait stability points.
        let gaitSamples: [SessionTransfer.GaitPoint] = gaitReadings.map { reading in
            SessionTransfer.GaitPoint(
                timestamp: start.addingTimeInterval(TimeInterval(reading.minuteOffset * 60)),
                score: reading.stability
            )
        }

        // Timeline: gabungkan sampel impairment berurutan yang levelnya sama.
        let timeline = buildTimelineSegments(sessionEnd: end)

        // Peak impairment.
        let peak = impairmentSamples.max { $0.score < $1.score }
        let peakScore = peak?.score ?? Double(100 - soberScore)
        let peakLevel = Self.impairmentRaw(peak?.level ?? currentLevel)

        // Averages.
        let avgHR: Double = hrSamples.isEmpty
            ? latestHeartRate
            : hrSamples.map { ($0.minBPM + $0.maxBPM) / 2 }.reduce(0, +) / Double(hrSamples.count)
        let avgStability: Double = gaitSamples.isEmpty
            ? 100
            : gaitSamples.map(\.score).reduce(0, +) / Double(gaitSamples.count)

        return SessionTransfer(
            id: UUID(),
            startDate: start,
            endDate: end,
            peakImpairmentScore: peakScore,
            peakLevel: peakLevel,
            averageHeartRate: avgHR,
            averageStability: avgStability,
            heartRateSamples: hrSamples,
            bodyGaitSamples: gaitSamples,
            timeline: timeline
        )
    }

    private func buildTimelineSegments(sessionEnd: Date) -> [SessionTransfer.TimelineSegment] {
        guard let first = impairmentSamples.first else {
            guard let start = sessionStartDate else { return [] }
            return [SessionTransfer.TimelineSegment(
                start: start,
                end: sessionEnd,
                impairmentScore: Double(100 - soberScore),
                level: Self.impairmentRaw(currentLevel)
            )]
        }

        var segments: [SessionTransfer.TimelineSegment] = []
        var segStart = first.date
        var segLevel = first.level
        var segPeak = first.score

        for sample in impairmentSamples.dropFirst() {
            if sample.level == segLevel {
                segPeak = max(segPeak, sample.score)
            } else {
                segments.append(SessionTransfer.TimelineSegment(
                    start: segStart,
                    end: sample.date,
                    impairmentScore: segPeak,
                    level: Self.impairmentRaw(segLevel)
                ))
                segStart = sample.date
                segLevel = sample.level
                segPeak = sample.score
            }
        }

        segments.append(SessionTransfer.TimelineSegment(
            start: segStart,
            end: sessionEnd,
            impairmentScore: segPeak,
            level: Self.impairmentRaw(segLevel)
        ))
        return segments
    }

    private static func impairmentRaw(_ level: SoberLevel) -> String {
        switch level {
        case .sober: return "sober"
        case .ok:    return "ok"
        case .tipsy: return "tipsy"
        case .drunk: return "drunk"
        }
    }
}

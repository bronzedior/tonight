//
//  HealthKitService.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import Foundation
import HealthKit

final class HealthKitService {

    // MARK: - Properties

    private let healthStore = HKHealthStore()

    private let heartRateType        = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let walkingSpeedType     = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
    private let walkingAsymmetryType = HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!
    private let doubleSupportType    = HKQuantityType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!

    /// Anchored query untuk real-time heart rate streaming
    private var heartRateQuery: HKAnchoredObjectQuery?

    /// Timer untuk polling walking metrics
    private var walkingPollTimer: Timer?

    /// Waktu mulai sesi (untuk filter query)
    private var sessionStartDate: Date?

    // MARK: - Callbacks

    /// Dipanggil saat ada data heart rate baru. Parameter: BPM, timestamp.
    var onNewHeartRate: ((Double, Date) -> Void)?

    /// Dipanggil saat ada data walking baru.
    /// Parameter: walkingSpeed (m/s), walkingAsymmetry (%), doubleSupportTime (%)
    var onNewWalkingData: ((Double?, Double?, Double?) -> Void)?

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [
            heartRateType,
            walkingSpeedType,
            walkingAsymmetryType,
            doubleSupportType
        ]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[HealthKitService] Authorization error: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }

    // MARK: - Start / Stop Monitoring

    func startMonitoring() {
        sessionStartDate = Date()
        startHeartRateStream()
        startWalkingMetricsPoll()
    }

    func stopMonitoring() {
        // Stop heart rate query
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }

        // Stop walking poll timer
        walkingPollTimer?.invalidate()
        walkingPollTimer = nil

        sessionStartDate = nil
    }

    // MARK: - Heart Rate Streaming (Real-Time)

    /// Menggunakan HKAnchoredObjectQuery untuk streaming heart rate secara continuous.
    /// Query ini akan terus menerima update setiap ada sampel HR baru di HealthKit.
    private func startHeartRateStream() {
        guard let startDate = sessionStartDate else { return }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: nil,
            options: .strictStartDate
        )

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, error in
            self?.processHeartRateSamples(samples)
        }

        // Update handler — dipanggil setiap ada data HR baru
        query.updateHandler = { [weak self] _, samples, _, _, error in
            self?.processHeartRateSamples(samples)
        }

        heartRateQuery = query
        healthStore.execute(query)
    }

    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }

        for sample in quantitySamples {
            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            let timestamp = sample.startDate

            DispatchQueue.main.async { [weak self] in
                self?.onNewHeartRate?(bpm, timestamp)
            }
        }
    }

    // MARK: - Walking Metrics Polling

    /// Walking metrics (speed, asymmetry, double support) tidak tersedia secara real-time
    /// seperti heart rate. Kita poll setiap 30 detik menggunakan HKStatisticsQuery.
    private func startWalkingMetricsPoll() {
        // Fetch immediately
        fetchLatestWalkingMetrics()

        // Then poll every 30 seconds
        walkingPollTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.fetchLatestWalkingMetrics()
        }
    }

    private func fetchLatestWalkingMetrics() {
        guard let startDate = sessionStartDate else { return }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: .strictStartDate
        )

        var latestSpeed: Double?
        var latestAsymmetry: Double?
        var latestDoubleSupport: Double?

        let group = DispatchGroup()

        // Walking Speed
        group.enter()
        let speedQuery = HKStatisticsQuery(
            quantityType: walkingSpeedType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, statistics, error in
            if let avg = statistics?.averageQuantity() {
                latestSpeed = avg.doubleValue(for: HKUnit.meter().unitDivided(by: .second()))
            }
            group.leave()
        }
        healthStore.execute(speedQuery)

        // Walking Asymmetry
        group.enter()
        let asymmetryQuery = HKStatisticsQuery(
            quantityType: walkingAsymmetryType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, statistics, error in
            if let avg = statistics?.averageQuantity() {
                latestAsymmetry = avg.doubleValue(for: .percent()) * 100
            }
            group.leave()
        }
        healthStore.execute(asymmetryQuery)

        // Double Support Time
        group.enter()
        let doubleSupportQuery = HKStatisticsQuery(
            quantityType: doubleSupportType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, statistics, error in
            if let avg = statistics?.averageQuantity() {
                latestDoubleSupport = avg.doubleValue(for: .percent()) * 100
            }
            group.leave()
        }
        healthStore.execute(doubleSupportQuery)

        group.notify(queue: .main) { [weak self] in
            // Hanya kirim callback jika setidaknya ada 1 data walking
            if latestSpeed != nil || latestAsymmetry != nil || latestDoubleSupport != nil {
                self?.onNewWalkingData?(latestSpeed, latestAsymmetry, latestDoubleSupport)
            }
        }
    }
}

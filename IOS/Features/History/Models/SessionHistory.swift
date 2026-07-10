//
//  SessionHistory.swift
//  tonight
//

import Foundation

/// Satu history session yang sudah selesai diproses Apple Watch.
///
/// Apple Watch bertanggung jawab untuk menghitung:
/// - impairment score
/// - impairment level
/// - body-gait score
/// - average values
///
/// iPhone hanya menerima, menyimpan, dan menampilkan hasilnya.
struct SessionHistory: Identifiable, Codable, Hashable {

    let id: UUID

    let startDate: Date

    let endDate: Date

    /// Peak level yang sudah ditentukan Watch.
    let peakLevel: ImpairmentLevel

    /// Peak impairment score yang sudah dihitung Watch.
    let peakScore: Double

    /// Average HR yang sudah dirangkum Watch.
    let averageHeartRate: Double

    /// Average body-gait/stability score dari Watch.
    let averageStability: Double

    /// History impairment score dari Watch.
    let timeline: [TimelinePoint]

    /// History heart rate dari Watch.
    let heartRateSamples: [HeartRateSample]

    /// History body-gait score yang sudah dihitung Watch.
    let bodyGaitSamples: [BodyGaitSample]

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        peakLevel: ImpairmentLevel,
        peakScore: Double,
        averageHeartRate: Double,
        averageStability: Double,
        timeline: [TimelinePoint],
        heartRateSamples: [HeartRateSample],
        bodyGaitSamples: [BodyGaitSample]
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.peakLevel = peakLevel
        self.peakScore = peakScore
        self.averageHeartRate = averageHeartRate
        self.averageStability = averageStability
        self.timeline = timeline
        self.heartRateSamples = heartRateSamples
        self.bodyGaitSamples = bodyGaitSamples
    }
}

// MARK: - Session Information

extension SessionHistory {

    var duration: TimeInterval {
        max(
            endDate.timeIntervalSince(startDate),
            0
        )
    }

    var highestHeartRateSample: HeartRateSample? {
        heartRateSamples.max {
            $0.maximumBPM < $1.maximumBPM
        }
    }

    var lowestBodyGaitSample: BodyGaitSample? {
        bodyGaitSamples.min {
            $0.score < $1.score
        }
    }

    var heartRateFactorMessage: String {
        guard let sample = highestHeartRateSample else {
            return "No heart rate data was recorded during this session."
        }

        let bpm = Int(
            sample.maximumBPM.rounded()
        )

        return """
        Your heart rate approached maximum (\(bpm) bpm) at \(formattedTime(sample.timestamp))
        """
    }

    var bodyGaitFactorMessage: String {
        guard let sample = lowestBodyGaitSample else {
            return "No body gait data was recorded during this session."
        }

        let score = Int(
            sample.score.rounded()
        )

        return """
        Your body reached its lowest stability (\(score)%) at \(formattedTime(sample.timestamp))
        """
    }
}

// MARK: - Formatting

private extension SessionHistory {

    func formattedTime(
        _ date: Date
    ) -> String {
        date.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }
}

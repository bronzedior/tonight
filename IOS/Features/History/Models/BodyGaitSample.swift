//
//  BodyGaitSample.swift
//  tonight
//

import Foundation

/// Nilai body-gait yang sudah dihitung di Apple Watch.
///
/// Watch menghitung nilai ini menggunakan:
/// - Walking Speed
/// - Walking Asymmetry
/// - Double Support Time
///
/// iPhone tidak menghitung ulang body-gait score.
struct BodyGaitSample: Identifiable, Codable, Hashable {

    let id: UUID

    let timestamp: Date

    /// Nilai hasil akhir dari Watch dalam rentang 0...100.
    let score: Double

    init(
        id: UUID = UUID(),
        timestamp: Date,
        score: Double
    ) {
        self.id = id
        self.timestamp = timestamp
        self.score = score
    }
}

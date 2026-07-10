//
//  TimelinePoint.swift
//  tonight
//

import Foundation

/// Satu bagian timeline impairment yang sudah dihitung oleh Watch.
///
/// iPhone hanya menyimpan dan menampilkan nilai ini.
struct TimelinePoint: Identifiable, Codable, Hashable {

    let id: UUID

    let startDate: Date

    let endDate: Date

    /// Impairment score yang sudah dihitung Apple Watch.
    let score: Double

    /// Impairment level yang sudah ditentukan Apple Watch.
    let level: ImpairmentLevel

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        score: Double,
        level: ImpairmentLevel
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.score = score
        self.level = level
    }

    var duration: TimeInterval {
        max(
            endDate.timeIntervalSince(startDate),
            0
        )
    }
}

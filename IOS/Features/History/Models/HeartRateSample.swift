//
//  HeartRateSample.swift
//  tonight
//

import Foundation

/// Rentang heart rate dalam satu interval waktu.
///
/// Nilai minimum dan maksimum nantinya sudah dirangkum
/// dan dikirim oleh Apple Watch.
///
/// iPhone hanya menyimpan dan menampilkan rentang tersebut.
struct HeartRateSample: Identifiable, Codable, Hashable {

    let id: UUID

    /// Awal interval pengukuran.
    let startDate: Date

    /// Akhir interval pengukuran.
    let endDate: Date

    /// Nilai heart rate terendah selama interval.
    let minimumBPM: Double

    /// Nilai heart rate tertinggi selama interval.
    let maximumBPM: Double

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        minimumBPM: Double,
        maximumBPM: Double
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate

        // Perlindungan agar nilai bawah tidak pernah
        // berada di atas nilai atas.
        self.minimumBPM = min(
            minimumBPM,
            maximumBPM
        )

        self.maximumBPM = max(
            minimumBPM,
            maximumBPM
        )
    }

    /// Posisi waktu tengah interval untuk peletakan batang.
    var timestamp: Date {
        startDate.addingTimeInterval(
            endDate.timeIntervalSince(startDate) / 2
        )
    }

    /// Nilai tengah untuk kebutuhan tampilan jika diperlukan.
    var midpointBPM: Double {
        (minimumBPM + maximumBPM) / 2
    }

    var duration: TimeInterval {
        max(
            endDate.timeIntervalSince(startDate),
            0
        )
    }
}

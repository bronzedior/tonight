//
//  FactorChartMetrics.swift
//  tonight
//
//  Created by Yuki Damanik on 10/07/26.
//

import SwiftUI

/// Sistem koordinat bersama untuk grafik factor.
///
/// Struct ini hanya mengubah data menjadi posisi visual.
/// Tidak melakukan perhitungan impairment atau body gait.
struct FactorChartMetrics {

    let size: CGSize

    let startDate: Date
    let endDate: Date

    let minimumValue: Double
    let maximumValue: Double

    let leadingInset: CGFloat
    let trailingInset: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat

    init(
        size: CGSize,
        startDate: Date,
        endDate: Date,
        minimumValue: Double,
        maximumValue: Double,
        leadingInset: CGFloat = 0,
        trailingInset: CGFloat = 36,
        topInset: CGFloat = 8,
        bottomInset: CGFloat = 28
    ) {
        self.size = size
        self.startDate = startDate
        self.endDate = endDate
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
        self.topInset = topInset
        self.bottomInset = bottomInset
    }

    var plotMinX: CGFloat {
        leadingInset
    }

    var plotMaxX: CGFloat {
        max(
            size.width - trailingInset,
            plotMinX
        )
    }

    var plotWidth: CGFloat {
        max(
            plotMaxX - plotMinX,
            1
        )
    }

    var plotMinY: CGFloat {
        topInset
    }

    var plotMaxY: CGFloat {
        max(
            size.height - bottomInset,
            plotMinY
        )
    }

    var plotHeight: CGFloat {
        max(
            plotMaxY - plotMinY,
            1
        )
    }

    var duration: TimeInterval {
        max(
            endDate.timeIntervalSince(startDate),
            1
        )
    }

    var valueRange: Double {
        max(
            maximumValue - minimumValue,
            1
        )
    }

    func x(
        for date: Date
    ) -> CGFloat {
        let elapsed =
            date.timeIntervalSince(startDate)

        let progress = min(
            max(elapsed / duration, 0),
            1
        )

        return plotMinX
            + CGFloat(progress) * plotWidth
    }

    func y(
        for value: Double
    ) -> CGFloat {
        let normalized =
            (value - minimumValue) / valueRange

        let progress = min(
            max(normalized, 0),
            1
        )

        return plotMaxY
            - CGFloat(progress) * plotHeight
    }

    func date(
        at progress: Double
    ) -> Date {
        let clampedProgress = min(
            max(progress, 0),
            1
        )

        return startDate.addingTimeInterval(
            duration * clampedProgress
        )
    }
}

//
//  TimelineLegend.swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

import SwiftUI

struct TimelineLegend: View {

    let points: [TimelinePoint]

    private let levels: [ImpairmentLevel] = [
        .sober,
        .ok,
        .tipsy,
        .drunk
    ]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(levels, id: \.self) { level in
                legendRow(for: level)
            }
        }
    }
}

// MARK: - Subviews

private extension TimelineLegend {

    func legendRow(
        for level: ImpairmentLevel
    ) -> some View {
        HStack(spacing: 11) {
            Circle()
                .fill(level.color)
                .frame(width: 17, height: 17)

            Text(level.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            durationLabel(for: level)
        }
    }

    func durationLabel(
        for level: ImpairmentLevel
    ) -> some View {
        let components = durationComponents(for: level)

        return HStack(
            alignment: .firstTextBaseline,
            spacing: 4
        ) {
            if components.hours > 0 {
                Text("\(components.hours)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Text("hr")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        Color.white.opacity(0.62)
                    )
            }

            if components.minutes > 0 || components.hours == 0 {
                Text("\(components.minutes)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Text("min")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        Color.white.opacity(0.62)
                    )
            }
        }
    }
}

// MARK: - Duration

private extension TimelineLegend {

    func durationComponents(
        for level: ImpairmentLevel
    ) -> (
        hours: Int,
        minutes: Int
    ) {
        let totalSeconds = points
            .filter { $0.level == level }
            .reduce(0.0) { partialResult, point in
                partialResult
                    + point.endDate.timeIntervalSince(
                        point.startDate
                    )
            }

        let totalMinutes = Int(totalSeconds / 60)

        return (
            hours: totalMinutes / 60,
            minutes: totalMinutes % 60
        )
    }
}

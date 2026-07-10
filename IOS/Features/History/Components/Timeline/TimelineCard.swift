//
//  TimelineCard..swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

import SwiftUI

struct TimelineCard: View {

    let session: SessionHistory

    private enum Layout {
        static let cornerRadius: CGFloat = 24
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 20
        static let chartHeight: CGFloat = 300
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            durationHeader

            TimelineRenderer(points: sortedPoints)
                .frame(height: Layout.chartHeight)

            TimelineLegend(points: sortedPoints)
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.vertical, Layout.verticalPadding)
        .background(cardBackground)
    }
}

// MARK: - Subviews

private extension TimelineCard {

    var durationHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Duration")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.62))

            durationValue
        }
    }

    var durationValue: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            if durationHours > 0 {
                Text("\(durationHours)")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(.white)

                Text("hr")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            Text("\(durationMinutes)")
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(.white)

            Text("min")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.72))
        }
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
            .fill(
                Color(
                    red: 17 / 255,
                    green: 27 / 255,
                    blue: 49 / 255
                )
            )
    }
}

// MARK: - Data

private extension TimelineCard {

    var sortedPoints: [TimelinePoint] {
        session.timeline.sorted {
            $0.startDate < $1.startDate
        }
    }

    var totalDuration: TimeInterval {
        guard
            let first = sortedPoints.first,
            let last = sortedPoints.last
        else {
            return 0
        }

        return max(
            last.endDate.timeIntervalSince(first.startDate),
            0
        )
    }

    var durationHours: Int {
        Int(totalDuration) / 3600
    }

    var durationMinutes: Int {
        (Int(totalDuration) % 3600) / 60
    }
}

#Preview {
    ZStack {
        Color(
            red: 5 / 255,
            green: 13 / 255,
            blue: 35 / 255
        )
        .ignoresSafeArea()

        TimelineCard(
            session: HistoryMock.sessions.first!
        )
        .padding()
    }
}

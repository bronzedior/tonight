//
//      TimelineXAxis.swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

import SwiftUI

struct TimelineXAxis: View {

    let metrics: TimelineRenderer.Metrics

    private let tickCount = 4

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0...tickCount, id: \.self) { index in
                tickLabel(at: index)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Subviews

private extension TimelineXAxis {

    func tickLabel(
        at index: Int
    ) -> some View {
        let date = metrics.date(atGridIndex: index)
        let x = metrics.gridX(at: index)

        return Text(timeText(for: date))
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(Color.white.opacity(0.62))
            .fixedSize()
            .position(
                x: adjustedX(
                    originalX: x,
                    index: index
                ),
                y: metrics.plotMaxY + 16
            )
    }

    func adjustedX(
        originalX: CGFloat,
        index: Int
    ) -> CGFloat {
        switch index {
        case 0:
            return originalX + 18

        case tickCount:
            return originalX - 18

        default:
            return originalX
        }
    }

    func timeText(
        for date: Date
    ) -> String {
        date.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }
}

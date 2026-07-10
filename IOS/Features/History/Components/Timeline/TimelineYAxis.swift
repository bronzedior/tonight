//
//  TimelineYAxis.swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

import SwiftUI

struct TimelineYAxis: View {

    let metrics: TimelineRenderer.Metrics

    private let levels: [ImpairmentLevel] = [
        .drunk,
        .tipsy,
        .ok,
        .sober
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(levels, id: \.self) { level in
                Text(level.title)
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        Color.white.opacity(0.88)
                    )
                    .frame(
                        width: metrics.plotMinX - 8,
                        alignment: .leading
                    )
                    .position(
                        x: (metrics.plotMinX - 8) / 2,
                        y: metrics.rowCenter(for: level)
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

//
//  TimelineGrid.swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

import SwiftUI

struct TimelineGrid: View {

    let metrics: TimelineRenderer.Metrics

    var body: some View {
        Canvas { context, _ in
            drawHorizontalLines(context: context)
            drawVerticalLines(context: context)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Drawing

private extension TimelineGrid {

    func drawHorizontalLines(
        context: GraphicsContext
    ) {
        for index in 1...4 {
            let y =
                metrics.plotMinY
                + CGFloat(index) * metrics.rowHeight

            var path = Path()

            path.move(
                to: CGPoint(
                    x: metrics.plotMinX,
                    y: y
                )
            )

            path.addLine(
                to: CGPoint(
                    x: metrics.plotMaxX,
                    y: y
                )
            )

            context.stroke(
                path,
                with: .color(
                    Color.white.opacity(0.24)
                ),
                lineWidth: 1
            )
        }
    }

    func drawVerticalLines(
        context: GraphicsContext
    ) {
        for index in 1...4 {
            let x = metrics.gridX(at: index)

            var path = Path()

            path.move(
                to: CGPoint(
                    x: x,
                    y: metrics.plotMinY
                )
            )

            path.addLine(
                to: CGPoint(
                    x: x,
                    y: metrics.plotMaxY
                )
            )

            context.stroke(
                path,
                with: .color(
                    Color.white.opacity(0.25)
                ),
                style: StrokeStyle(
                    lineWidth: 1,
                    dash: [3, 3]
                )
            )
        }
    }
}

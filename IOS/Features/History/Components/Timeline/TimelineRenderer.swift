//
//  TimelineRenderer.swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

import SwiftUI

struct TimelineRenderer: View {

    let points: [TimelinePoint]

    private enum Layout {
        static let labelWidth: CGFloat = 72
        static let chartTop: CGFloat = 12
        static let chartBottom: CGFloat = 34
        static let blockHeight: CGFloat = 44
        static let blockCornerRadius: CGFloat = 6
        static let rowCount: CGFloat = 4
        static let verticalGridCount = 4
        static let horizontalInset: CGFloat = 2
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = Metrics(
                points: sortedPoints,
                size: proxy.size
            )

            ZStack(alignment: .topLeading) {
                TimelineGrid(metrics: metrics)
                TimelineYAxis(metrics: metrics)
                stepConnector(metrics: metrics)
                statusBlocks(metrics: metrics)
                TimelineXAxis(metrics: metrics)
            }
            .clipped()
        }
    }
}

// MARK: - Metrics

extension TimelineRenderer {

    struct Metrics {

        let points: [TimelinePoint]
        let size: CGSize
        let startDate: Date
        let endDate: Date
        let duration: TimeInterval

        var plotMinX: CGFloat {
            Layout.labelWidth
        }

        var plotMaxX: CGFloat {
            size.width - Layout.horizontalInset
        }

        var plotWidth: CGFloat {
            max(plotMaxX - plotMinX, 1)
        }

        var plotMinY: CGFloat {
            Layout.chartTop
        }

        var plotMaxY: CGFloat {
            size.height - Layout.chartBottom
        }

        var plotHeight: CGFloat {
            max(plotMaxY - plotMinY, 1)
        }

        var rowHeight: CGFloat {
            plotHeight / Layout.rowCount
        }

        init(
            points: [TimelinePoint],
            size: CGSize
        ) {
            self.points = points
            self.size = size

            let firstDate = points.first?.startDate ?? .now
            let lastDate = points.last?.endDate ?? firstDate

            startDate = firstDate
            endDate = lastDate
            duration = max(
                lastDate.timeIntervalSince(firstDate),
                1
            )
        }

        func x(for date: Date) -> CGFloat {
            let elapsed = date.timeIntervalSince(startDate)
            let progress = min(max(elapsed / duration, 0), 1)

            return plotMinX + CGFloat(progress) * plotWidth
        }

        func rowCenter(for level: ImpairmentLevel) -> CGFloat {
            let visualRow: CGFloat

            switch level {
            case .drunk:
                visualRow = 0
            case .tipsy:
                visualRow = 1
            case .ok:
                visualRow = 2
            case .sober:
                visualRow = 3
            }

            return plotMinY
                + visualRow * rowHeight
                + rowHeight / 2
        }

        func blockFrame(for point: TimelinePoint) -> CGRect {
            let startX = x(for: point.startDate)
            let endX = x(for: point.endDate)
            let width = max(endX - startX, 2)
            let centerY = rowCenter(for: point.level)

            return CGRect(
                x: startX,
                y: centerY - Layout.blockHeight / 2,
                width: width,
                height: Layout.blockHeight
            )
        }

        func gridX(at index: Int) -> CGFloat {
            let progress =
                CGFloat(index)
                / CGFloat(Layout.verticalGridCount)

            return plotMinX + progress * plotWidth
        }

        func date(atGridIndex index: Int) -> Date {
            let progress =
                Double(index)
                / Double(Layout.verticalGridCount)

            return startDate.addingTimeInterval(
                duration * progress
            )
        }
    }
}

// MARK: - Drawing

private extension TimelineRenderer {

    var sortedPoints: [TimelinePoint] {
        points.sorted {
            $0.startDate < $1.startDate
        }
    }

    @ViewBuilder
    func statusBlocks(
        metrics: Metrics
    ) -> some View {
        ForEach(metrics.points) { point in
            let frame = metrics.blockFrame(for: point)

            RoundedRectangle(
                cornerRadius: Layout.blockCornerRadius,
                style: .continuous
            )
            .fill(point.level.color)
            .overlay {
                RoundedRectangle(
                    cornerRadius: Layout.blockCornerRadius,
                    style: .continuous
                )
                .stroke(
                    Color.white.opacity(0.65),
                    lineWidth: 1
                )
            }
            .frame(
                width: frame.width,
                height: frame.height
            )
            .position(
                x: frame.midX,
                y: frame.midY
            )
        }
    }

    @ViewBuilder
    func stepConnector(
        metrics: Metrics
    ) -> some View {
        Path { path in
            guard metrics.points.count > 1 else {
                return
            }

            for index in 0..<(metrics.points.count - 1) {
                let current = metrics.points[index]
                let next = metrics.points[index + 1]

                let currentFrame =
                    metrics.blockFrame(for: current)

                let nextFrame =
                    metrics.blockFrame(for: next)

                let connectorX = currentFrame.maxX

                path.move(
                    to: CGPoint(
                        x: connectorX,
                        y: currentFrame.midY
                    )
                )

                path.addLine(
                    to: CGPoint(
                        x: connectorX,
                        y: nextFrame.midY
                    )
                )
            }
        }
        .stroke(
            Color.white.opacity(0.78),
            style: StrokeStyle(
                lineWidth: 2,
                lineCap: .square,
                lineJoin: .round
            )
        )
    }
}

#Preview {
    ZStack {
        Color(
            red: 17 / 255,
            green: 27 / 255,
            blue: 49 / 255
        )

        TimelineRenderer(
            points: HistoryMock.sessions.first!.timeline
        )
        .frame(height: 300)
        .padding()
    }
}

//
//  BodyGaitChart.swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

//
//  BodyGaitChart.swift
//  tonight
//
//  Created by Yuki Damanik on 09/07/26.
//

import SwiftUI

struct BodyGaitChart: View {

    let samples: [BodyGaitSample]

    private enum Layout {

        static let verticalGridCount = 8

        static let minimumScore: Double = 0

        static let maximumScore: Double = 100

        /// Gradient memudar sampai 70% dari nilai setiap data.
        static let gradientFadeRatio: Double = 0.10

        /// Blur cahaya di sekitar garis atas.
        static let glowBlurRadius: CGFloat = 8

        static let lineWidth: CGFloat = 2
    
        static let maximumXAxisLabels = 6
    }

    private var sortedSamples: [BodyGaitSample] {
        samples.sorted {
            $0.timestamp < $1.timestamp
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = makeMetrics(
                size: proxy.size
            )

            ZStack(alignment: .topLeading) {
                chartGrid(metrics: metrics)

                bodyGaitArea(metrics: metrics)

                bodyGaitLine(metrics: metrics)

                xAxis(metrics: metrics)

                yAxis(metrics: metrics)
            }
            .clipped()
        }
    }
}

// MARK: - Metrics

private extension BodyGaitChart {

    func makeMetrics(
        size: CGSize
    ) -> FactorChartMetrics {
        let firstDate =
            sortedSamples.first?.timestamp
            ?? Date()

        let lastDate =
            sortedSamples.last?.timestamp
            ?? firstDate.addingTimeInterval(1)

        return FactorChartMetrics(
            size: size,
            startDate: firstDate,
            endDate: lastDate,
            minimumValue:
                Layout.minimumScore,
            maximumValue:
                Layout.maximumScore,
            trailingInset: 38,
            topInset: 8,
            bottomInset: 28
        )
    }
}

// MARK: - Grid

private extension BodyGaitChart {

    func chartGrid(
        metrics: FactorChartMetrics
    ) -> some View {
        Canvas { context, _ in
            drawHorizontalLines(
                context: context,
                metrics: metrics
            )

            drawVerticalLines(
                context: context,
                metrics: metrics
            )

            drawSideBorders(
                context: context,
                metrics: metrics
            )
        }
        .allowsHitTesting(false)
    }

    func drawHorizontalLines(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        let values: [Double] = [
            0,
            50,
            100
        ]

        for value in values {
            let y = metrics.y(for: value)

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
                    Color.white.opacity(
                        value == 50
                            ? 0.28
                            : 0.18
                    )
                ),
                style: StrokeStyle(
                    lineWidth: 1,
                    dash: value == 50
                        ? [3, 3]
                        : []
                )
            )
        }
    }

    func drawVerticalLines(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        for index in 1..<Layout.verticalGridCount {
            let progress =
                CGFloat(index)
                / CGFloat(
                    Layout.verticalGridCount
                )

            let x =
                metrics.plotMinX
                + progress * metrics.plotWidth

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
                    Color.white.opacity(0.24)
                ),
                style: StrokeStyle(
                    lineWidth: 1,
                    dash: [3, 3]
                )
            )
        }
    }

    func drawSideBorders(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        var leftPath = Path()

        leftPath.move(
            to: CGPoint(
                x: metrics.plotMinX,
                y: metrics.plotMinY
            )
        )

        leftPath.addLine(
            to: CGPoint(
                x: metrics.plotMinX,
                y: metrics.plotMaxY
            )
        )

        context.stroke(
            leftPath,
            with: .color(
                Color.white.opacity(0.38)
            ),
            lineWidth: 1
        )

        var rightPath = Path()

        rightPath.move(
            to: CGPoint(
                x: metrics.plotMaxX,
                y: metrics.plotMinY
            )
        )

        rightPath.addLine(
            to: CGPoint(
                x: metrics.plotMaxX,
                y: metrics.plotMaxY
            )
        )

        context.stroke(
            rightPath,
            with: .color(
                Color.white.opacity(0.38)
            ),
            lineWidth: 1
        )
    }
}

// MARK: - Body Gait Area

private extension BodyGaitChart {

    func bodyGaitArea(
        metrics: FactorChartMetrics
    ) -> some View {
        Canvas { context, _ in
            guard sortedSamples.count > 1 else {
                return
            }

            drawFaintBaseArea(
                context: context,
                metrics: metrics
            )

            drawPerSampleGradient(
                context: context,
                metrics: metrics
            )

            drawTopGlow(
                context: context,
                metrics: metrics
            )
        }
        .allowsHitTesting(false)
    }
    
    func bodyGaitLine(
        metrics: FactorChartMetrics
    ) -> some View {
        Canvas { context, _ in
            guard sortedSamples.count > 1 else {
                return
            }

            var path = Path()

            for (
                index,
                sample
            ) in sortedSamples.enumerated() {
                let point = CGPoint(
                    x: metrics.x(
                        for: sample.timestamp
                    ),
                    y: metrics.y(
                        for: sample.score
                    )
                )

                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }

            context.stroke(
                path,
                with: .color(gaitColor),
                style: StrokeStyle(
                    lineWidth:
                        Layout.lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
        .allowsHitTesting(false)
    }

    var gaitColor: Color {
        Color(
            red: 48 / 255,
            green: 209 / 255,
            blue: 88 / 255
        )
    }
    
    func drawFaintBaseArea(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        guard
            let firstSample = sortedSamples.first,
            let lastSample = sortedSamples.last
        else {
            return
        }

        var path = Path()

        path.move(
            to: CGPoint(
                x: metrics.x(
                    for: firstSample.timestamp
                ),
                y: metrics.plotMaxY
            )
        )

        for sample in sortedSamples {
            path.addLine(
                to: CGPoint(
                    x: metrics.x(
                        for: sample.timestamp
                    ),
                    y: metrics.y(
                        for: sample.score
                    )
                )
            )
        }

        path.addLine(
            to: CGPoint(
                x: metrics.x(
                    for: lastSample.timestamp
                ),
                y: metrics.plotMaxY
            )
        )

        path.closeSubpath()

        context.fill(
            path,
            with: .color(
                gaitColor.opacity(0.05)
            )
        )
    }
    
    func drawPerSampleGradient(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        guard sortedSamples.count > 1 else {
            return
        }

        for index in 0..<(sortedSamples.count - 1) {
            let current = sortedSamples[index]
            let next = sortedSamples[index + 1]

            let currentX = metrics.x(
                for: current.timestamp
            )

            let nextX = metrics.x(
                for: next.timestamp
            )

            let currentTopY = metrics.y(
                for: current.score
            )

            let nextTopY = metrics.y(
                for: next.score
            )

            /*
             Gradient bagian bawah mengikuti 70%
             dari nilai setiap sampel.

             Contoh:
             score 80 -> gradient berakhir di score 56.
             */
            let currentFadeScore =
                current.score
                * Layout.gradientFadeRatio

            let nextFadeScore =
                next.score
                * Layout.gradientFadeRatio

            let currentFadeY = metrics.y(
                for: currentFadeScore
            )

            let nextFadeY = metrics.y(
                for: nextFadeScore
            )

            var segmentPath = Path()

            segmentPath.move(
                to: CGPoint(
                    x: currentX,
                    y: currentTopY
                )
            )

            segmentPath.addLine(
                to: CGPoint(
                    x: nextX,
                    y: nextTopY
                )
            )

            segmentPath.addLine(
                to: CGPoint(
                    x: nextX,
                    y: nextFadeY
                )
            )

            segmentPath.addLine(
                to: CGPoint(
                    x: currentX,
                    y: currentFadeY
                )
            )

            segmentPath.closeSubpath()

            let averageTopY =
                (currentTopY + nextTopY) / 2

            let averageFadeY =
                (currentFadeY + nextFadeY) / 2

            context.fill(
                segmentPath,
                with: .linearGradient(
                    Gradient(
                        stops: [
                            .init(
                                color:
                                    gaitColor.opacity(0.95),
                                location: 0
                            ),
                            .init(
                                color:
                                    gaitColor.opacity(0.52),
                                location: 0.35
                            ),
                            .init(
                                color:
                                    gaitColor.opacity(0.15),
                                location: 0.72
                            ),
                            .init(
                                color:
                                    gaitColor.opacity(0),
                                location: 1
                            )
                        ]
                    ),
                    startPoint: CGPoint(
                        x: (currentX + nextX) / 2,
                        y: averageTopY
                    ),
                    endPoint: CGPoint(
                        x: (currentX + nextX) / 2,
                        y: averageFadeY
                    )
                )
            )
        }
    }
    
    func drawTopGlow(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        guard sortedSamples.count > 1 else {
            return
        }

        var glowPath = Path()

        for (index, sample) in sortedSamples.enumerated() {
            let point = CGPoint(
                x: metrics.x(
                    for: sample.timestamp
                ),
                y: metrics.y(
                    for: sample.score
                )
            )

            if index == 0 {
                glowPath.move(to: point)
            } else {
                glowPath.addLine(to: point)
            }
        }

        context.drawLayer { glowContext in
            glowContext.addFilter(
                .blur(
                    radius: Layout.glowBlurRadius
                )
            )

            glowContext.stroke(
                glowPath,
                with: .color(
                    gaitColor.opacity(0.75)
                ),
                style: StrokeStyle(
                    lineWidth: 7,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}

// MARK: - X Axis

private extension BodyGaitChart {

    func xAxis(
        metrics: FactorChartMetrics
    ) -> some View {
        let dates = visibleXAxisDates(
            metrics: metrics
        )

        return ZStack(alignment: .topLeading) {
            ForEach(
                Array(dates.enumerated()),
                id: \.offset
            ) { index, date in
                xAxisLabel(
                    date: date,
                    index: index,
                    totalCount: dates.count,
                    metrics: metrics
                )
            }
        }
        .allowsHitTesting(false)
    }
    
    func roundedMinuteInterval(
        _ rawInterval: Double
    ) -> Int {
        let supportedIntervals = [
            10,
            20,
            30,
            40,
            60
        ]

        return supportedIntervals.first {
            Double($0) >= rawInterval
        } ?? 60
    }
    
    func visibleXAxisDates(
        metrics: FactorChartMetrics
    ) -> [Date] {
        let totalDurationMinutes =
            Int(metrics.duration / 60)

        guard totalDurationMinutes > 0 else {
            return [metrics.startDate]
        }

        let maximumLabels =
            Layout.maximumXAxisLabels

        let rawInterval =
            Double(totalDurationMinutes)
            / Double(maximumLabels - 1)

        let roundedInterval =
            roundedMinuteInterval(rawInterval)

        var dates: [Date] = []
        var minuteOffset = 0

        while minuteOffset <= totalDurationMinutes {
            let date =
                metrics.startDate.addingTimeInterval(
                    TimeInterval(minuteOffset * 60)
                )

            dates.append(date)

            minuteOffset += roundedInterval
        }

        if let lastDate = dates.last,
           lastDate < metrics.endDate,
           dates.count < maximumLabels {
            dates.append(metrics.endDate)
        }

        return dates
    }

    func xAxisLabel(
        date: Date,
        index: Int,
        totalCount: Int,
        metrics: FactorChartMetrics
    ) -> some View {
        let x = metrics.x(for: date)

        return Text(formattedTime(date))
            .font(
                .system(
                    size: 11,
                    weight: .regular
                )
            )
            .foregroundStyle(
                Color.white.opacity(0.68)
            )
            .fixedSize()
            .position(
                x: adjustedXAxisPosition(
                    x,
                    index: index,
                    totalCount: totalCount
                ),
                y: metrics.plotMaxY + 16
            )
    }
    
    func adjustedXAxisPosition(
        _ x: CGFloat,
        index: Int,
        totalCount: Int
    ) -> CGFloat {
        if index == 0 {
            return x + 18
        }

        if index == totalCount - 1 {
            return x - 18
        }

        return x
    }

    func adjustedXAxisPosition(
        _ x: CGFloat,
        index: Int
    ) -> CGFloat {
        if index == 0 {
            return x + 18
        }

        if index ==
            Layout.verticalGridCount {
            return x - 18
        }

        return x
    }

    func formattedTime(
        _ date: Date
    ) -> String {
        date.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }
}

// MARK: - Y Axis

private extension BodyGaitChart {

    func yAxis(
        metrics: FactorChartMetrics
    ) -> some View {
        ZStack(alignment: .topLeading) {
            yAxisLabel(
                title: "100%",
                value: 100,
                metrics: metrics
            )

            yAxisLabel(
                title: "50%",
                value: 50,
                metrics: metrics
            )
        }
        .allowsHitTesting(false)
    }

    func yAxisLabel(
        title: String,
        value: Double,
        metrics: FactorChartMetrics
    ) -> some View {
        Text(title)
            .font(
                .system(
                    size: 11,
                    weight: .regular
                )
            )
            .foregroundStyle(
                Color.white.opacity(0.62)
            )
            .position(
                x: metrics.plotMaxX + 19,
                y: metrics.y(for: value)
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

        BodyGaitChart(
            samples:
                HistoryMock.previewBodyGaitSamples
        )
        .frame(height: 220)
        .padding()
    }
}

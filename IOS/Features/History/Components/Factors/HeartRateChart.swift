//
//  HeartRateChart.swift
//  tonight
//

import SwiftUI

struct HeartRateChart: View {

    let samples: [HeartRateSample]

    private enum ChartConstant {
        static let minimumHeartRate: Double = 0
        static let maximumHeartRate: Double = 200
        static let sampleIntervalMinutes = 10
        static let labelIntervalMinutes = 20
        static let maximumXAxisLabels = 6
        static let barWidth: CGFloat = 14
        static let minimumBarHeight: CGFloat = 16
        static let barCornerRadius: CGFloat = 7
        static let trailingInset: CGFloat = 40
        static let topInset: CGFloat = 8
        static let bottomInset: CGFloat = 30
        
    }

    private var sortedSamples: [HeartRateSample] {
        samples.sorted {
            $0.startDate < $1.startDate
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = makeMetrics(
                size: proxy.size
            )

            ZStack(alignment: .topLeading) {
                grid(metrics: metrics)

                rangeBars(metrics: metrics)

                xAxis(metrics: metrics)

                yAxis(metrics: metrics)
            }
            .clipped()
        }
    }
}

// MARK: - Metrics

private extension HeartRateChart {

    func makeMetrics(
        size: CGSize
    ) -> FactorChartMetrics {
        let firstDate =
            sortedSamples.first?.startDate
            ?? Date()

        let lastDate =
            sortedSamples.last?.endDate
            ?? firstDate.addingTimeInterval(1)

        return FactorChartMetrics(
            size: size,
            startDate: firstDate,
            endDate: lastDate,
            minimumValue:
                ChartConstant.minimumHeartRate,
            maximumValue:
                ChartConstant.maximumHeartRate,
            trailingInset:
                ChartConstant.trailingInset,
            topInset:
                ChartConstant.topInset,
            bottomInset:
                ChartConstant.bottomInset
        )
    }
}

// MARK: - Grid

private extension HeartRateChart {

    func grid(
        metrics: FactorChartMetrics
    ) -> some View {
        Canvas { context, _ in
            drawHorizontalGrid(
                context: context,
                metrics: metrics
            )

            drawVerticalGrid(
                context: context,
                metrics: metrics
            )

            drawSideBorders(
                context: context,
                metrics: metrics
            )

            drawBottomBorder(
                context: context,
                metrics: metrics
            )
        }
        .allowsHitTesting(false)
    }

    func drawHorizontalGrid(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        let referenceValues: [Double] = [
            100
        ]

        for value in referenceValues {
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
                    Color.white.opacity(0.30)
                ),
                style: StrokeStyle(
                    lineWidth: 1,
                    dash: [4, 4]
                )
            )
        }
    }

    func drawVerticalGrid(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        let dates = visibleXAxisDates(
            metrics: metrics
        )

        for date in dates.dropFirst().dropLast() {
            let x = metrics.x(for: date)

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
                    Color.white.opacity(0.28)
                ),
                style: StrokeStyle(
                    lineWidth: 1,
                    dash: [4, 4]
                )
            )
        }
    }

    func drawSideBorders(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        var leftBorder = Path()

        leftBorder.move(
            to: CGPoint(
                x: metrics.plotMinX,
                y: metrics.plotMinY
            )
        )

        leftBorder.addLine(
            to: CGPoint(
                x: metrics.plotMinX,
                y: metrics.plotMaxY
            )
        )

        context.stroke(
            leftBorder,
            with: .color(
                Color.white.opacity(0.36)
            ),
            lineWidth: 1
        )

        var rightBorder = Path()

        rightBorder.move(
            to: CGPoint(
                x: metrics.plotMaxX,
                y: metrics.plotMinY
            )
        )

        rightBorder.addLine(
            to: CGPoint(
                x: metrics.plotMaxX,
                y: metrics.plotMaxY
            )
        )

        context.stroke(
            rightBorder,
            with: .color(
                Color.white.opacity(0.36)
            ),
            lineWidth: 1
        )
    }

    func drawBottomBorder(
        context: GraphicsContext,
        metrics: FactorChartMetrics
    ) {
        var path = Path()

        path.move(
            to: CGPoint(
                x: metrics.plotMinX,
                y: metrics.plotMaxY
            )
        )

        path.addLine(
            to: CGPoint(
                x: metrics.plotMaxX,
                y: metrics.plotMaxY
            )
        )

        context.stroke(
            path,
            with: .color(
                Color.white.opacity(0.36)
            ),
            lineWidth: 1
        )
    }
}

// MARK: - Range Bars

private extension HeartRateChart {

    func rangeBars(
        metrics: FactorChartMetrics
    ) -> some View {
        ForEach(sortedSamples) { sample in
            rangeBar(
                sample: sample,
                metrics: metrics
            )
        }
    }

    func rangeBar(
        sample: HeartRateSample,
        metrics: FactorChartMetrics
    ) -> some View {
        let upperY = metrics.y(
            for: sample.maximumBPM
        )

        let lowerY = metrics.y(
            for: sample.minimumBPM
        )

        let rawHeight = lowerY - upperY

        let barHeight = max(
            rawHeight,
            ChartConstant.minimumBarHeight
        )

        let centerY = upperY + rawHeight / 2

        return Capsule(style: .continuous)
            .fill(heartRateColor)
            .frame(
                width: ChartConstant.barWidth,
                height: barHeight
            )
            .position(
                x: metrics.x(
                    for: sample.timestamp
                ),
                y: centerY
            )
    }

    var heartRateColor: Color {
        Color(
            red: 1,
            green: 91 / 255,
            blue: 99 / 255
        )
    }
}

// MARK: - X Axis

private extension HeartRateChart {

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

    func visibleXAxisDates(
        metrics: FactorChartMetrics
    ) -> [Date] {
        let totalDurationMinutes =
            max(
                Int(metrics.duration / 60),
                1
            )

        let maximumLabels =
            ChartConstant.maximumXAxisLabels

        let rawInterval =
            Double(totalDurationMinutes)
            / Double(max(maximumLabels - 1, 1))

        let intervalMinutes =
            roundedMinuteInterval(rawInterval)

        var dates: [Date] = []
        var minuteOffset = 0

        while minuteOffset <= totalDurationMinutes {
            let date =
                metrics.startDate.addingTimeInterval(
                    TimeInterval(minuteOffset * 60)
                )

            dates.append(date)
            minuteOffset += intervalMinutes
        }

        /*
         End date hanya ditambahkan bila masih tersedia ruang.
         Ini mencegah dua label terakhir saling bertabrakan.
         */
        if
            let lastDate = dates.last,
            lastDate < metrics.endDate,
            dates.count < maximumLabels
        {
            dates.append(metrics.endDate)
        }

        return dates
    }

    func roundedMinuteInterval(
        _ rawInterval: Double
    ) -> Int {
        let supportedIntervals = [
            10,
            20,
            30,
            40,
            60,
            90,
            120
        ]

        return supportedIntervals.first {
            Double($0) >= rawInterval
        } ?? 120
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
            return x + 19
        }

        if index == totalCount - 1 {
            return x - 19
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

private extension HeartRateChart {

    func yAxis(
        metrics: FactorChartMetrics
    ) -> some View {
        ZStack(alignment: .topLeading) {
            yAxisLabel(
                title: "200",
                value: 200,
                metrics: metrics
            )

            yAxisLabel(
                title: "100",
                value: 100,
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
                    size: 12,
                    weight: .regular
                )
            )
            .foregroundStyle(
                Color.white.opacity(0.68)
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

        HeartRateChart(
            samples:
                HistoryMock.previewHeartRateSamples
        )
        .frame(height: 220)
        .padding()
    }
}

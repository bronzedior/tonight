//
//  HeartRateChartView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI
import Charts

struct HeartRateChartView: View {
    var readings: [HeartRateReading]
    var heartColor = Color(red: 1.0, green: 0.42, blue: 0.42)
    var minBPM: Int { readings.map(\.bpmLow).min() ?? 0 }
    var maxBPM: Int { readings.map(\.bpmHigh).max() ?? 0 }
    
    @Binding var isMonitoring: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Heart Rate")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 8)
            
            Chart(readings) { reading in
                BarMark(
                    x: .value("Minute", reading.minuteOffset),
                    yStart: .value("Low", reading.bpmLow),
                    yEnd: .value("High", reading.bpmHigh),
                    width: .fixed(3)
                )
                .foregroundStyle(heartColor)
                .cornerRadius(1)
            }
            .chartYScale(domain: 50...180)
            .chartXScale(domain: -1...36)
            .chartXAxis {
                AxisMarks(values: [0, 10, 20, 30]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.4))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text(String(format: "%02d", v))
                                .font(.system(size: 9))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: [50, 180]) { value in
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(.system(size: 9))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            Text("Range")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(minBPM) - \(maxBPM)")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                Text("BPM")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white)
            }
            Text("Current")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.gray)
        }
        .closeSession(isMonitoring: $isMonitoring)
        .padding(.horizontal, 10)
        .containerBackground(.black, for: .tabView)
    }
}

#Preview("Heart Rate") {
    HeartRateChartView(readings: DummyDataProvider.shared.heartRateReadings, isMonitoring: .constant(true))
}















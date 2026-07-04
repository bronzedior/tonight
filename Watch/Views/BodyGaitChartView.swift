//
//  BodyGaitChartView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 04/07/26.
//

import SwiftUI
import Charts

struct BodyGaitChartView: View {
    var readings: [GaitReading]
    var gaitColor = Color.cyan
    
    @Binding var isMonitoring: Bool
    
    private var averageStability: Double {
        guard !readings.isEmpty else { return 0 }
        let total = readings.reduce(0.0) { $0 + $1.stability }
        return total / Double(readings.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Body Gait")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(gaitColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 8)
            
            Chart(readings) { reading in
                AreaMark(
                    x: .value("Minute", reading.minuteOffset),
                    y: .value("Stability", reading.stability)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [gaitColor.opacity(0.3), gaitColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Minute", reading.minuteOffset),
                    y: .value("Stability", reading.stability)
                )
                .foregroundStyle(gaitColor)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartYScale(domain: 0...100)
            .chartXScale(domain: -1...36)
            .chartXAxis {
                AxisMarks(values: [0, 10, 20, 30]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(.gray.opacity(0.4))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text(v == 0 ? "Min" : String(format: "%02d", v))
                                .font(.system(size: 9))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: [50, 100]) { value in
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)%")
                                .font(.system(size: 9))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            Text("Stability")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(averageStability.rounded()))")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                Text("%")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white)
            }
            Text("Average")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.gray)
        }
        .closeSession(isMonitoring: $isMonitoring)
        .padding(.horizontal, 10)
        .containerBackground(.black, for: .tabView)
    }
}

#Preview("Body Gait") {
    BodyGaitChartView(readings: DummyDataProvider.shared.gaitReadings, isMonitoring: .constant(true))
}

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
    var titleColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    var dotColor = Color(red: 0.0, green: 0.9, blue: 0.3)
    
    @Binding var isMonitoring: Bool
    
    var currentStability: Double {
        readings.last?.stability ?? 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Body Gait")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(titleColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 8)
            
            Chart(readings) { reading in
                PointMark(
                    x: .value("Minute", reading.minuteOffset),
                    y: .value("Stability", reading.stability)
                )
                .foregroundStyle(dotColor)
                                .symbolSize(50)            }
            .chartYScale(domain: -0.5...10.5)
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
                AxisMarks(position: .trailing, values: [0, 10]) { value in
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
            
            Text("Stable")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", currentStability))
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                Text("%")
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

#Preview("Body Gait") {
    BodyGaitChartView(readings: DummyDataProvider.shared.gaitReadings, isMonitoring: .constant(true))
}

//
//  CircularGauge.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 04/07/26.
//

import SwiftUI

struct CircularGauge: View {
    var progress: Double
    var lineWidth: CGFloat = 14
    var trackColor: Color = Color(white: 0.20)
    var progressColor: Color = .green
    var arcFraction: Double = 0.75
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: arcFraction)
                .stroke(
                    trackColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(135))

            Circle()
                .trim(from: 0, to: arcFraction * clampedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
        }
    }
    
    var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}

#Preview("Gauge 100 %") {
    CircularGauge(
        progress: 1,
        progressColor: Color(red: 0, green: 0.9, blue: 0.8)
    )
    .frame(width: 120, height: 120)
    .preferredColorScheme(.dark)
}

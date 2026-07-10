//
//  SoberScoreView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI

struct SoberScoreView: View {
    var score: Int
    var date: Date
    var heartRate: Int
    var gaitScore: Int
    
    var soberLevel: SoberLevel {
        SoberLevel.from(score: score)
    }
    
    @State var showInfo: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                // Top row: time + status label
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("Status")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, -18)
                
                Spacer()
                
                // Center: sober level label
                VStack(spacing: 4) {
                    Text(soberLevel.rawValue)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(soberLevel.color)
                    
                    Text(soberLevel.subtitle)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Bottom: heart rate & gait indicators
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                    Text("\(heartRate)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("·")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.gray)
                    
                    Image(systemName: "figure.walk")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                    Text("\(gaitScore)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 4)
            }
            
            // Info button (top-left)
            Button { showInfo.toggle() } label: {
                Image(systemName: "info")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(white: 0.25))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .offset(x: -2, y: -37)
        }
        .padding(.horizontal, 10)
        .containerBackground(.black, for: .tabView)
        .sheet(isPresented: $showInfo) {
            InfoSheetView(
                soberLevel: soberLevel,
                timeRange: "21.39-02.34",
                hrRange: "90-140 BPM",
                stability: "70%"
            )
        }
    }
}

#Preview("Score 100 — SOBER") {
    SoberScoreView(score: 100, date: Date(), heartRate: 79, gaitScore: 99)
}

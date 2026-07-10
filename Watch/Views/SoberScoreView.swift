//
//  SoberScoreView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI

struct SoberScoreView: View {
    @ObservedObject var viewModel: SessionViewModel

    var soberLevel: SoberLevel {
        SoberLevel.from(score: viewModel.soberScore)
    }

    @State var animatedProgress: Double = 0
    @State var showInfo: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Sober Score")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 8)

            ZStack {
                CircularGauge(
                    progress: animatedProgress,
                    lineWidth: 14,
                    trackColor: Color(white: 0.20),
                    progressColor: soberLevel.color
                )
                Text("\(viewModel.soberScore)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(soberLevel.color)
                    .contentTransition(.numericText())
            }
            .frame(width: 120, height: 120)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)

            HStack(spacing: 6) {
                Text(soberLevel.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(soberLevel.color)

                Button { showInfo.toggle() } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(.indigo)
                }
                .buttonStyle(.plain)
            }

            Text(viewModel.sessionDate, format: .dateTime.day().month(.abbreviated))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.gray)
        }
        .closeSession(isMonitoring: $viewModel.isMonitoring) {
            viewModel.stopSession()
        }
        .padding(.horizontal, 10)
        .containerBackground(.black, for: .tabView)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animatedProgress = Double(viewModel.soberScore) / 100.0
            }
        }
        .onChange(of: viewModel.soberScore) { _, newScore in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = Double(newScore) / 100.0
            }
        }
        .sheet(isPresented: $showInfo) {
            infoSheet
        }
    }

    var infoSheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("How It Works")
                    .font(.headline)
                Text("Sober Score is calculated from health metrics compared to your baseline:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        Text("Heart Rate (30%)")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                    }
                    Label {
                        Text("Walking Speed (20%)")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "figure.walk")
                            .foregroundStyle(.cyan)
                    }
                    Label {
                        Text("Walking Asymmetry (30%)")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "figure.walk.diamond.fill")
                            .foregroundStyle(.orange)
                    }
                    Label {
                        Text("Double Support (20%)")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "shoe.2.fill")
                            .foregroundStyle(.green)
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    scoreRangeRow("80–100", "SOBER", SoberLevel.sober.color)
                    scoreRangeRow("60–79",  "OK",    SoberLevel.ok.color)
                    scoreRangeRow("40–59",  "SEMI-DRUNK", SoberLevel.semiDrunk.color)
                    scoreRangeRow("0–39",   "DRUNK", SoberLevel.drunk.color)
                }
            }
            .padding()
        }
    }

    func scoreRangeRow(_ range: String, _ label: String, _ color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(range)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(label)
                .font(.caption2)
                .bold()
                .foregroundStyle(color)
        }
    }
}

#Preview("Score 100 — SOBER") {
    SoberScoreView(viewModel: SessionViewModel())
}

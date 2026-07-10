//
//  HistorySummaryHeader.swift
//  tonight
//

import SwiftUI

struct HistorySummaryHeader: View {

    @ObservedObject var viewModel:
        HistoryViewModel

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            dateSelector

            if let session =
                viewModel.selectedSession {
                scoreSummary(session)
                    .padding(.top, 30)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .overlay(
            alignment: .topLeading
        ) {
            dateDropdownOverlay
        }
        .zIndex(20)
    }
}

// MARK: - Date Selector

private extension HistorySummaryHeader {

    var dateSelector: some View {
        DateSelectorButton(
            title: viewModel.selectedDateText,
            isPresented:
                viewModel.isShowingDatePopover
        ) {
            withAnimation(
                .easeInOut(duration: 0.20)
            ) {
                viewModel.toggleDatePopover()
            }
        }
    }

    @ViewBuilder
    var dateDropdownOverlay: some View {
        if viewModel.isShowingDatePopover {
            DateSelectorPopover(
                sessions: viewModel.sessions,
                selectedSessionID:
                    viewModel.selectedSession?.id
            ) { session in
                withAnimation(
                    .easeInOut(duration: 0.20)
                ) {
                    viewModel.selectSession(
                        session
                    )
                }
            }
            .offset(
                x: 0,
                y: 0
            )
            .transition(
                .opacity.combined(
                    with: .scale(
                        scale: 0.96,
                        anchor: .topLeading
                    )
                )
            )
            .zIndex(100)
        }
    }
}

// MARK: - Score Summary

private extension HistorySummaryHeader {

    func scoreSummary(
        _ session: SessionHistory
    ) -> some View {
        VStack(spacing: 22) {
            scoreInformation(session)

            peakStatusPill(session)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .center
        )
        .background {
            scoreGlow(
                color:
                    session.peakLevel.glowColor
            )
        }
    }

    func scoreInformation(
        _ session: SessionHistory
    ) -> some View {
        VStack(spacing: 12) {
            Text(session.peakLevel.title)
                .font(
                    .system(
                        size: 38,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)

            Label {
                Text(
                    "Avg HR: \(Int(session.averageHeartRate.rounded()))"
                )
            } icon: {
                Image(systemName: "heart.fill")
            }

            Label {
                Text(
                    "Avg Stability: \(Int(session.averageStability.rounded()))"
                )
            } icon: {
                Image(systemName: "figure.walk")
            }
        }
        .font(
            .system(
                size: 16,
                weight: .semibold
            )
        )
        .foregroundStyle(.white)
        .frame(
            maxWidth: .infinity,
            alignment: .center
        )
    }

    func peakStatusPill(
        _ session: SessionHistory
    ) -> some View {
        HStack(spacing: 4) {
            Text("Peak Status:")
                .fontWeight(.semibold)

            Text(
                session.peakLevel.statusTitle
            )
        }
        .font(
            .system(
                size: 15,
                weight: .regular
            )
        )
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 38)
        .background {
            Capsule(style: .continuous)
                .fill(
                    session
                        .peakLevel
                        .statusColor
                )
        }
        .padding(.horizontal, 50)
    }
}

// MARK: - Glow

private extension HistorySummaryHeader {

    func scoreGlow(
        color: Color
    ) -> some View {
        ZStack {
            Ellipse()
                .fill(
                    color.opacity(0.28)
                )
                .frame(
                    width: 260,
                    height: 210
                )
                .blur(radius: 54)

            Ellipse()
                .fill(
                    color.opacity(0.17)
                )
                .frame(
                    width: 180,
                    height: 150
                )
                .blur(radius: 34)
        }
        .offset(y: -8)
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color(
            red: 5 / 255,
            green: 13 / 255,
            blue: 35 / 255
        )
        .ignoresSafeArea()

        HistorySummaryHeader(
            viewModel: HistoryViewModel()
        )
        .padding(.horizontal, 20)
    }
}    

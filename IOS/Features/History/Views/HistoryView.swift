//
//  HistoryView.swift
//  tonight
//

import SwiftUI

struct HistoryView: View {

    @StateObject private var viewModel =
        HistoryViewModel()

    @State private var scrollPosition: CGFloat = 0

    private enum Layout {
        static let compactHeaderThreshold: CGFloat = 64
        static let compactHeaderHeight: CGFloat = 62
        static let animationDuration: Double = 0.20
        static let compactDropdownTopOffset: CGFloat = 58
    }

    var body: some View {
        ZStack(alignment: .top) {
            pageBackground

            historyScrollContent
                .zIndex(
                    viewModel.isShowingDatePopover
                    && !isCompactHeaderVisible
                    ? 300
                    : 0
                )

            if isCompactHeaderVisible {
                compactHeader
                    .transition(
                        .opacity
                    )
                    .zIndex(100)
            }
            
            dismissDropdownLayer
                .zIndex(150)

            compactDateDropdownLayer
                .zIndex(200)
        }
        .animation(
            .easeInOut(
                duration: Layout.animationDuration
            ),
            value: isCompactHeaderVisible
        )
        .preferredColorScheme(.dark)
        .sheet(
            isPresented:
                $viewModel.isShowingScoreSheet
        ) {
            AboutScoreSheet()
        }
    }
}

// MARK: - State

private extension HistoryView {

    var isCompactHeaderVisible: Bool {
        scrollPosition >
            Layout.compactHeaderThreshold
    }
}

// MARK: - Scroll Content

private extension HistoryView {

    var historyScrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                largeHeader

                if let session =
                    viewModel.selectedSession {
                    summaryContent(session)

                    sessionContent(session)
                } else {
                    EmptyHistoryView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollClipDisabled()
        .onScrollGeometryChange(
            for: CGFloat.self
        ) { geometry in
            geometry.contentOffset.y
                + geometry.contentInsets.top
        } action: { _, newValue in
            scrollPosition = max(
                newValue,
                0
            )
        }
    }
}

// MARK: - Large Header

private extension HistoryView {

    var largeHeader: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            largeTitleRow

            largeDateSelector
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .zIndex(300)
    }

    var largeTitleRow: some View {
        HStack(alignment: .center) {
            Text("History")
                .font(
                    .system(
                        size: 44,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)

            Spacer()

            largeInfoButton
        }
    }

    var largeInfoButton: some View {
        Button {
            viewModel
                .isShowingScoreSheet = true
        } label: {
            Image(systemName: "info")
                .font(
                    .system(
                        size: 20,
                        weight: .medium
                    )
                )
                .foregroundStyle(.white)
                .frame(
                    width: 54,
                    height: 54
                )
                .background {
                    Circle()
                        .fill(
                            Color.black.opacity(0.28)
                        )
                }
                .overlay {
                    Circle()
                        .stroke(
                            Color.white.opacity(0.28),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "About impairment score"
        )
    }

    var largeDateSelector: some View {
        DateSelectorButton(
            title: viewModel.selectedDateText,
            isPresented:
                viewModel.isShowingDatePopover
                && !isCompactHeaderVisible
        ) {
            toggleDatePopover()
        }
        .overlay(alignment: .topLeading) {
            if
                viewModel.isShowingDatePopover,
                !isCompactHeaderVisible
            {
                DateSelectorPopover(
                    sessions: viewModel.sessions,
                    selectedSessionID:
                        viewModel.selectedSession?.id
                ) { session in
                    withAnimation(
                        .easeInOut(
                            duration:
                                Layout.animationDuration
                        )
                    ) {
                        viewModel.selectSession(session)
                    }
                }
                .frame(
                    height: 360,
                    alignment: .top
                )
                .fixedSize(
                    horizontal: false,
                    vertical: false
                )
                .transition(
                    .opacity.combined(
                        with: .scale(
                            scale: 0.96,
                            anchor: .topLeading
                        )
                    )
                )
                .zIndex(400)
            }
        }
        .zIndex(400)
    }
}

// MARK: - Compact Header

private extension HistoryView {

    var compactHeader: some View {
        ZStack(alignment: .top) {
            compactHeaderBackground
                .frame(
                    height: Layout.compactHeaderHeight + 22
                )

            ZStack {
                compactCenteredTitle

                HStack {
                    Spacer()

                    compactInfoButton
                }
                .padding(.horizontal, 20)
            }
            .frame(
                height: Layout.compactHeaderHeight
            )
        }
        .frame(maxWidth: .infinity)
        .frame(
            height: Layout.compactHeaderHeight + 22
        )
    }

    var compactCenteredTitle: some View {
        Button {
            toggleDatePopover()
        } label: {
            VStack(spacing: 1) {
                Text("History")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)

                HStack(spacing: 4) {
                    Text(
                        viewModel.selectedDateText
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(
                        Color.white.opacity(0.66)
                    )
                    .lineLimit(1)

                    Image(
                        systemName:
                            viewModel
                                .isShowingDatePopover
                            ? "chevron.up"
                            : "chevron.down"
                    )
                    .font(
                        .system(
                            size: 9,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        Color.white.opacity(0.60)
                    )
                }
            }
            .frame(
                minWidth: 130,
                minHeight: 44
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "Select history date"
        )
    }

    var compactInfoButton: some View {
        Button {
            viewModel
                .isShowingScoreSheet = true
        } label: {
            Image(systemName: "info")
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.white)
                .frame(
                    width: 40,
                    height: 40
                )
                .background {
                    Circle()
                        .fill(
                            Color.black.opacity(0.24)
                        )
                }
                .overlay {
                    Circle()
                        .stroke(
                            Color.white.opacity(0.18),
                            lineWidth: 0.8
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "About impairment score"
        )
    }

    var compactHeaderBackground: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay {
                LinearGradient(
                    stops: [
                        .init(
                            color: pageBackgroundColor.opacity(0.82),
                            location: 0
                        ),
                        .init(
                            color: pageBackgroundColor.opacity(0.62),
                            location: 0.55
                        ),
                        .init(
                            color: pageBackgroundColor.opacity(0.28),
                            location: 0.82
                        ),
                        .init(
                            color: Color.clear,
                            location: 1
                        )
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .mask {
                LinearGradient(
                    stops: [
                        .init(
                            color: .white,
                            location: 0
                        ),
                        .init(
                            color: .white,
                            location: 0.72
                        ),
                        .init(
                            color: .white.opacity(0.72),
                            location: 0.88
                        ),
                        .init(
                            color: .clear,
                            location: 1
                        )
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Compact Dropdown

private extension HistoryView {

    @ViewBuilder
    var compactDateDropdownLayer: some View {
        if
            viewModel.isShowingDatePopover,
            isCompactHeaderVisible
        {
            VStack(spacing: 0) {
                DateSelectorPopover(
                    sessions:
                        viewModel.sessions,
                    selectedSessionID:
                        viewModel
                            .selectedSession?
                            .id
                ) { session in
                    withAnimation(
                        .easeInOut(
                            duration:
                                Layout.animationDuration
                        )
                    ) {
                        viewModel.selectSession(
                            session
                        )
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .offset(
                y:
                    Layout
                        .compactDropdownTopOffset
            )
            .transition(
                datePopoverTransition
            )
        }
    }

    var datePopoverTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: 0.96,
                anchor: .top
            )
        )
    }

    func toggleDatePopover() {
        withAnimation(
            .easeInOut(
                duration:
                    Layout.animationDuration
            )
        ) {
            viewModel.toggleDatePopover()
        }
    }

    @ViewBuilder
    var dismissDropdownLayer: some View {
        if
            viewModel.isShowingDatePopover,
            isCompactHeaderVisible
        {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(
                        .easeInOut(
                            duration:
                                Layout.animationDuration
                        )
                    ) {
                        viewModel
                            .isShowingDatePopover =
                            false
                    }
                }
        }
    }
}

// MARK: - Score Summary

private extension HistoryView {

    func summaryContent(
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
        .padding(.vertical, 34)
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
            Text(
                session.peakLevel.title
            )
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
                Image(
                    systemName: "heart.fill"
                )
            }

            Label {
                Text(
                    "Avg Stability: \(Int(session.averageStability.rounded()))"
                )
            } icon: {
                Image(
                    systemName: "figure.walk"
                )
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
                session
                    .peakLevel
                    .statusTitle
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

    func scoreGlow(
        color: Color
    ) -> some View {
        ZStack {
            Ellipse()
                .fill(
                    color.opacity(0.26)
                )
                .frame(
                    width: 320,
                    height: 250
                )
                .blur(radius: 60)

            Ellipse()
                .fill(
                    color.opacity(0.16)
                )
                .frame(
                    width: 230,
                    height: 190
                )
                .blur(radius: 40)
        }
        .offset(y: -4)
        .padding(.vertical, -46)
        .allowsHitTesting(false)
    }
}

// MARK: - Session Content

private extension HistoryView {

    func sessionContent(
        _ session: SessionHistory
    ) -> some View {
        VStack(spacing: 24) {
            TimelineCard(
                session: session
            )

            factorsTitle

            FactorCard(
                title: "Heart Rate",
                message:
                    session
                        .heartRateFactorMessage,
                icon: "heart.fill",
                tint: heartRateColor
            ) {
                HeartRateChart(
                    samples:
                        session
                            .heartRateSamples
                )
            }

            FactorCard(
                title: "Body Gait",
                message:
                    session
                        .bodyGaitFactorMessage,
                icon: "figure.walk",
                tint: bodyGaitColor
            ) {
                BodyGaitChart(
                    samples:
                        session
                            .bodyGaitSamples
                )
            }
        }
    }

    var factorsTitle: some View {
        Text("Factors")
            .font(
                .system(
                    size: 27,
                    weight: .bold
                )
            )
            .foregroundStyle(.white)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.top, 4)
    }
}

// MARK: - Appearance

private extension HistoryView {

    var pageBackground: some View {
        pageBackgroundColor
            .ignoresSafeArea()
    }

    var pageBackgroundColor: Color {
        Color(
            red: 5 / 255,
            green: 13 / 255,
            blue: 35 / 255
        )
    }

    var heartRateColor: Color {
        Color(
            red: 1,
            green: 91 / 255,
            blue: 99 / 255
        )
    }

    var bodyGaitColor: Color {
        Color(
            red: 48 / 255,
            green: 209 / 255,
            blue: 88 / 255
        )
    }
}

#Preview {
    HistoryView()
}

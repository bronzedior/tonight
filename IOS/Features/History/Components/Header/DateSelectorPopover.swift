//
//  DateSelectorPopover.swift
//  tonight
//

import SwiftUI

struct DateSelectorPopover: View {

    let sessions: [SessionHistory]
    let selectedSessionID: UUID?
    let onSelect: (SessionHistory) -> Void

    private let menuWidth: CGFloat = 305
    private let maximumHeight: CGFloat = 330
    private let cornerRadius: CGFloat = 30
    private let rowHeight: CGFloat = 78

    private var sortedSessions: [SessionHistory] {
        sessions.sorted {
            $0.startDate > $1.startDate
        }
    }

    var body: some View {
        menuContent
            .frame(width: menuWidth)
            .frame(maxHeight: maximumHeight)
            .modifier(
                DateSelectorGlassEffect(
                    cornerRadius: cornerRadius
                )
            )
            .shadow(
                color: Color.black.opacity(0.34),
                radius: 22,
                x: 0,
                y: 14
            )
    }
}

// MARK: - Menu Content

private extension DateSelectorPopover {

    var menuContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(sortedSessions) { session in
                    sessionRow(session)
                }
            }
        }
        .clipShape(menuShape)
        .contentShape(menuShape)
    }

    var menuShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )
    }
}

// MARK: - Row

private extension DateSelectorPopover {

    func sessionRow(
        _ session: SessionHistory
    ) -> some View {
        Button {
            onSelect(session)
        } label: {
            HStack(spacing: 14) {
                selectionIndicator(for: session)

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text(dateTitle(for: session))
                        .font(
                            .system(
                                size: 19,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .shadow(
                            color: Color.black.opacity(0.28),
                            radius: 1,
                            x: 0,
                            y: 1
                        )

                    Text(session.peakLevel.title)
                        .font(
                            .system(
                                size: 15,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(
                            Color.white.opacity(0.68)
                        )
                        .shadow(
                            color: Color.black.opacity(0.22),
                            radius: 1,
                            x: 0,
                            y: 1
                        )
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(
                maxWidth: .infinity,
                minHeight: rowHeight,
                alignment: .leading
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func selectionIndicator(
        for session: SessionHistory
    ) -> some View {
        if selectedSessionID == session.id {
            Image(systemName: "checkmark")
                .font(
                    .system(
                        size: 21,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.white)
                .frame(width: 24)
                .shadow(
                    color: Color.black.opacity(0.28),
                    radius: 1,
                    x: 0,
                    y: 1
                )
        } else {
            Color.clear
                .frame(width: 24, height: 24)
        }
    }
}

// MARK: - Formatting

private extension DateSelectorPopover {

    func dateTitle(
        for session: SessionHistory
    ) -> String {
        session.startDate.formatted(
            .dateTime
                .month(.wide)
                .day()
                .year()
        )
    }
}

// MARK: - Glass Effect

private struct DateSelectorGlassEffect: ViewModifier {

    let cornerRadius: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay {
                            shape
                                .fill(
                                    Color.black.opacity(0.20)
                                )
                        }
                        .clipShape(shape)
                }
                .glassEffect(
                    .clear.interactive(),
                    in: shape
                )
                .overlay {
                    shape
                        .stroke(
                            Color.white.opacity(0.05),
                            lineWidth: 0.6
                        )
                        .allowsHitTesting(false)
                }
                .clipShape(shape)

        } else {
            content
                .background {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay {
                            shape
                                .fill(
                                    Color.black.opacity(0.24)
                                )
                        }
                }
                .clipShape(shape)
        }
    }
}

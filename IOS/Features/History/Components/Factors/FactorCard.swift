//
//  FactorCard.swift
//  tonight
//

import SwiftUI

private enum FactorCardLayout {

    static let cornerRadius: CGFloat = 24
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 20
    static let chartHeight: CGFloat = 220
}

struct FactorCard<ChartContent: View>: View {

    let title: String
    let message: String
    let icon: String
    let tint: Color

    private let chartContent: ChartContent

    init(
        title: String,
        message: String,
        icon: String,
        tint: Color,
        @ViewBuilder chartContent: () -> ChartContent
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.tint = tint
        self.chartContent = chartContent()
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            header

            Text(message)
                .font(
                    .system(
                        size: 18,
                        weight: .regular
                    )
                )
                .foregroundStyle(.white)
                .lineSpacing(4)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            chartContent
                .frame(
                    height: FactorCardLayout.chartHeight
                )
        }
        .padding(
            .horizontal,
            FactorCardLayout.horizontalPadding
        )
        .padding(
            .vertical,
            FactorCardLayout.verticalPadding
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(cardBackground)
    }
}

// MARK: - Subviews

private extension FactorCard {

    var header: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(
                    .system(
                        size: 19,
                        weight: .semibold
                    )
                )
                .foregroundStyle(tint)

            Text(title)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(tint)

            Spacer()
        }
    }

    var cardBackground: some View {
        RoundedRectangle(
            cornerRadius: FactorCardLayout.cornerRadius,
            style: .continuous
        )
        .fill(
            Color(
                red: 17 / 255,
                green: 27 / 255,
                blue: 49 / 255
            )
        )
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

        FactorCard(
            title: "Heart Rate",
            message: "Your heart rate approached maximum (188 bpm) at 11.36",
            icon: "heart.fill",
            tint: Color(
                red: 1,
                green: 91 / 255,
                blue: 99 / 255
            )
        ) {
            Rectangle()
                .fill(
                    Color.white.opacity(0.04)
                )
        }
        .padding()
    }
}

//
//  AboutScoreSheet.swift
//  tonight
//
//  Created by Yuki Damanik on 08/07/26.
//

import SwiftUI

struct AboutScoreSheet: View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ZStack {
            sheetBackground

            VStack(spacing: 0) {
                customHeader

                ScrollView(showsIndicators: false) {
                    informationCard
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDragIndicator(.visible)
        .presentationBackground(
            sheetBackgroundColor
        )
    }
}

// MARK: - Header

private extension AboutScoreSheet {

    var customHeader: some View {
        ZStack {
            Text("About")
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.white)

            HStack {
                Spacer()

                closeButton
            }
        }
        .frame(height: 64)
        .padding(.horizontal, 20)
    }

    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Circle()
                .fill(closeButtonColor)
                .frame(
                    width: 44,
                    height: 44
                )
                .overlay {
                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 18,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            Color.white.opacity(0.82)
                        )
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}

// MARK: - Main Content

private extension AboutScoreSheet {

    var informationCard: some View {
        VStack(
            alignment: .leading,
            spacing: 30
        ) {
            textSection(
                title: "About Impairment Score",
                description:
                    """
                    Your impairment score is estimated by comparing changes in your heart rate and body gait with your personal baseline. This score reflects how your body responds over time and is intended for awareness, not as a medical or legal measurement.
                    """
            )

            textSection(
                title: "How Your Score is Calculated?",
                description:
                    """
                    Your score is calculated by combining multiple health indicators into a single estimate. Rather than relying on one measurement, Tonight evaluates how changes across different signals collectively contribute to your estimated impairment level.
                    """
            )

            levelSection(
                title: "Sober",
                description:
                    """
                    Your health signals remain consistent with your personal baseline, indicating little to no detectable impairment.
                    """
            )

            levelSection(
                title: "OK",
                description:
                    """
                    Small changes are detected, but your heart rate and body gait remain relatively close to your personal baseline.
                    """
            )

            levelSection(
                title: "Tipsy",
                description:
                    """
                    Noticeable changes are detected across your monitored signals compared with your personal baseline.
                    """
            )

            levelSection(
                title: "Drunk",
                description:
                    """
                    Strong changes are detected across your monitored signals. Consider stopping alcohol consumption and prioritizing your safety.
                    """
            )

            textSection(
                title: "Important",
                description:
                    """
                    Tonight does not measure blood alcohol concentration and must not be used to determine whether it is safe or legal to drive.
                    """
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(cardBackgroundColor)
        }
    }

    func levelSection(
        title: String,
        description: String
    ) -> some View {
        textSection(
            title: title,
            description: description
        )
    }

    func textSection(
        title: String,
        description: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text(title)
                .font(
                    .system(
                        size: 23,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)

            Text(description)
                .font(
                    .system(
                        size: 17,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    secondaryTextColor
                )
                .lineSpacing(7)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
    }
}

// MARK: - Colors

private extension AboutScoreSheet {

    var sheetBackground: some View {
        sheetBackgroundColor
            .ignoresSafeArea()
    }

    var sheetBackgroundColor: Color {
        Color(
            red: 28 / 255,
            green: 28 / 255,
            blue: 30 / 255
        )
    }

    var cardBackgroundColor: Color {
        Color(
            red: 44 / 255,
            green: 44 / 255,
            blue: 46 / 255
        )
    }

    var closeButtonColor: Color {
        Color(
            red: 66 / 255,
            green: 66 / 255,
            blue: 70 / 255
        )
    }

    var secondaryTextColor: Color {
        Color(
            red: 174 / 255,
            green: 174 / 255,
            blue: 178 / 255
        )
    }
}

#Preview {
    AboutScoreSheet()
}

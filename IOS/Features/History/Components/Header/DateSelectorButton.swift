//
//  DateSelectorButton.swift
//  tonight
//

import SwiftUI

struct DateSelectorButton: View {

    let title: String
    let isPresented: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(
                        .system(
                            size: 17,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Image(
                    systemName:
                        isPresented
                        ? "chevron.up"
                        : "chevron.down"
                )
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    Color.white.opacity(0.86)
                )
            }
            .padding(.horizontal, 18)
            .frame(height: 46)
            .background(buttonBackground)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Appearance

private extension DateSelectorButton {

    var buttonBackground: some View {
        Capsule(style: .continuous)
            .fill(
                Color.white.opacity(0.11)
            )
            .overlay {
                Capsule(style: .continuous)
                    .stroke(
                        Color.white.opacity(0.06),
                        lineWidth: 1
                    )
            }
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

        DateSelectorButton(
            title: "April 1, 2026",
            isPresented: false,
            action: {}
        )
    }
}

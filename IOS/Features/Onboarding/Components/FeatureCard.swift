//
//  FeatureCard.swift
//  tonight
//
//  Created by Yuki Damanik on 06/07/26.
//

import SwiftUI

struct FeatureCard: View {

    let icon: String
    let title: String

    var body: some View {

        VStack(spacing: 0) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 45, weight: .regular))
                .foregroundStyle(.white)
                .frame(height: 70)

            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.7))

            Spacer()
                .frame(height: 28)

        }
        .frame(width: 110, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

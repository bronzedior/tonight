//
//  OnboardingContainer.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct OnboardingContainer<Header: View, Content: View>: View {

    let title: String
    let subtitle: String
    let content: Content
    let header: Header
    let buttonTitle: String
    let buttonAction: () -> Void
    let isButtonEnabled: Bool

    init(
        title: String,
        subtitle: String,
        buttonTitle: String,
        isButtonEnabled: Bool = true,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        buttonAction: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.header = header()
        self.content = content()
        self.buttonAction = buttonAction
        self.isButtonEnabled = isButtonEnabled
    }

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.6),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                header

                VStack(spacing: 8) {

                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }
                
                content

                Spacer()

                PrimaryButton(
                    title: buttonTitle,
                    action: buttonAction
                )
                .disabled(!isButtonEnabled)
                .opacity(isButtonEnabled ? 1 : 0.5)
            }
            .padding(.horizontal,24)
            .padding(.bottom,40)
        }
    }
}

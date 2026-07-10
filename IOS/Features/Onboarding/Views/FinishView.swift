//
//  FinishView.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
// aku

import SwiftUI

struct FinishView: View {

    @ObservedObject
    var viewModel: OnboardingViewModel

    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    var body: some View {

        OnboardingContainer(

            title: "You're all set!",
            subtitle: "Tonight is ready to help you stay safe while drinking.",
            buttonTitle: "Start Using Tonight",
            header: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(.green)
            },
            content: {
                
            },
            buttonAction: {
                hasCompletedOnboarding = true
            }
        )
    }
}

#Preview {
    FinishView(viewModel: OnboardingViewModel())
}

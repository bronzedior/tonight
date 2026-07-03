//
//  HowItWorks.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct HowItWorksView: View {
    
    @ObservedObject
    var viewModel: OnboardingViewModel
    
    var body: some View {

        OnboardingContainer(
            title: "How it works",
            subtitle: "Your Apple Watch tracks body signals and compares them with your personal baseline",
            buttonTitle: "Continue",
            header: {
                Image(systemName: "waveform.path.ecg")
                    .font(.largeTitle)
            },
            content: {
                HStack(spacing: 32) {
                    VStack {
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                        Text("Heart Rate")
                    }
                    
                    VStack {
                        Image(systemName: "figure.walk")
                            .font(.largeTitle)
                        Text("Body Gait")
                    }
                }
                .foregroundStyle(.white)
            },
            buttonAction: {
                viewModel.next()
            }
        )
    }
}

#Preview {
    HowItWorksView(viewModel: OnboardingViewModel())
}

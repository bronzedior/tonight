//
//  OnboardingView.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject
    private var viewModel = OnboardingViewModel()
    
    var body: some View {
        switch viewModel.currentStep {
        case 0:
            WelcomeView {
                viewModel.next()
            }
            
        case 1:
            HowItWorksView(viewModel: viewModel)
            
        case 2:
            ConnectWatchView(viewModel: viewModel)

        case 3:
            HealthPermissionView(viewModel: viewModel)

        case 4:
            FinishView(viewModel: viewModel)

        default:
            EmptyView()
        }
    }
}

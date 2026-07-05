//
//  HealthPermissionView.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct HealthPermissionView: View {

    @ObservedObject
    var viewModel: OnboardingViewModel

    var body: some View {

        OnboardingContainer(

            title: "Allow Health Access",
            subtitle: "We only read the health data required to estimate your condition. Your data never leaves your device.",
            buttonTitle: "Allow Access",
            header: {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)

            },
            content: {
                VStack(alignment: .leading, spacing: 18) {
                    Label("Heart Rate",
                          systemImage: "heart.fill")
                    Label("Walking Speed",
                          systemImage: "figure.walk")
                    Label("Walking Stability",
                          systemImage: "figure.walk.motion")
                }
                .foregroundStyle(.white)
            },

            buttonAction: {
                HealthKitManager.shared.requestAuthorization {
                    success in
                    if success {
                        viewModel.healthPermissionGranted = true
                        viewModel.next()
                    } else {
                        viewModel.showPermissionDenied = true
                        
                    }

                }

            }

        )
        
        .alert(
                "Health Access Required",
                isPresented: $viewModel.showPermissionDenied
            ) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(
                    "Tonight needs access to Heart Rate and Motion data to monitor your condition."
                )
            }
    }

}

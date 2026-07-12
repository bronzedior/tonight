//
//  StartView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: SessionViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            LottieAnimationView(fileName: "BeerBottle")
                .frame(width: 140, height: 150)

            Spacer()

            // Start button — minta izin HealthKit, mulai stream HR + CoreMotion,
            // lalu kalibrasi baseline. Layar calibrating/all-set ditangani di
            // tonightApp berdasarkan viewModel.baselinePhase.
            Button {
                viewModel.startSession()
            } label: {
                Text("Start")
                    .font(.system(size: 20, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(white: 0.25))
            .clipShape(Capsule())
        }
        .containerBackground(.black, for: .tabView)
    }
}

#Preview("Start") {
    StartView(viewModel: SessionViewModel())
}

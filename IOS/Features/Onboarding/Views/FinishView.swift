//
//  FinishView.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct FinishView: View {

    @ObservedObject
    var viewModel: OnboardingViewModel

    var body: some View {

        VStack {

            Spacer()

            Text("You're all set!")

            Spacer()

            PrimaryButton(title: "Start Monitoring") {
                viewModel.next()
            }

        }
    }

}

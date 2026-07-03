//
//  ConnectWatchView.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct ConnectWatchView: View {

    @ObservedObject
    var viewModel: OnboardingViewModel

    var body: some View {

        VStack {

            Spacer()

            Text("Connect Apple Watch")

            Spacer()

            PrimaryButton(title: "Continue") {
                viewModel.next()
            }

        }
    }
}

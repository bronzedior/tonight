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

        OnboardingContainer(

            title: "Works seamlessly with your Apple Watch",

            subtitle: "Tonight automatically monitors your body signals from your Apple Watch while \n you're drinking. Just wear your watch \n and we'll do the rest.",

            buttonTitle: "Continue",

            header: {

                Image(systemName: "applewatch.side.right")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)

            },

            content: {

            },

            buttonAction: {

                viewModel.next()

            }

        )

    }

}

#Preview {
    
    ConnectWatchView(viewModel: OnboardingViewModel())
    
}

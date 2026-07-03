//
//  WelcomeView.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct WelcomeView: View {
    let onNext: () -> Void
    var body : some View {
        OnboardingContainer(
            title: "Stay in control.\nEvery time you drink.",
            subtitle: "Using your Apple Watch, Tonight estimates your condition through body signals.",
            buttonTitle: "Get Started",
            header: {
                Image(systemName: "wineglass")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            },
            content: {
                EmptyView()
            },
            buttonAction: {
                onNext()
            }
        )
    }
}

#Preview {
    WelcomeView(onNext: {})
}

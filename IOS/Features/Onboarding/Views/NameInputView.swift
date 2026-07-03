//
//  NameInputView.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import SwiftUI

struct NameInputView: View {
    
    @ObservedObject
    var viewModel: OnboardingViewModel
    
    var body: some View {

        OnboardingContainer(
            title: "What Should I call you?",
            subtitle: "We'll use your name to personalize your experience",
            buttonTitle: "Continue",
            header: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            },
            content: {
                TextField(
                    "Your name",
                    text: $viewModel.username
                )
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            },
            buttonAction: {
                viewModel.next()
            }
            
        )

    }

}

#Preview {
    NameInputView(viewModel: OnboardingViewModel())
}

//
//  StartView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 04/07/26.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: SessionViewModel

    var body: some View {
        VStack {
            Spacer()
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

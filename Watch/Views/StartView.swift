//
//  StartView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 04/07/26.
//

import SwiftUI

struct StartView: View {
    @Binding var isMonitoring: Bool
    var body: some View {
        VStack {
            Spacer()
            Button {
                isMonitoring = true
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
    StartView(isMonitoring: .constant(false))
}

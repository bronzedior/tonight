//
//  AllSetModifier.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 09/07/26.
//

import SwiftUI

struct AllSetView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.15, blue: 0.8),
                    Color(red: 0.2, green: 0.4, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Text("All set")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    AllSetView()
}

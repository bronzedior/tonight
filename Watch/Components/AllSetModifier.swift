//
//  AllSetModifier.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 09/07/26.
//

import SwiftUI
import WatchKit

struct AllSetView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                LottieAnimationView(fileName: "Checkmark")
                    .frame(width: 140, height: 140)
            }
        }
        .onAppear {
            // Feedback selesai kalibrasi — haptic + bunyi khas watch (mirip notif).
            WKInterfaceDevice.current().play(.success)
        }
    }
}

#Preview {
    AllSetView()
}

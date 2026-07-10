//
//  StartView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI

struct StartView: View {
    @Binding var isMonitoring: Bool
    enum ScreenState {
        case start
        case calibrating
        case allSet
    }
    @State var currentState: ScreenState = .start
    var body: some View {
        ZStack {
            switch currentState {
            case .start:
                startContent
            case .calibrating:
                CalibratingView()
            case .allSet:
                AllSetView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentState)
    }
    
    var startContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            LottieAnimationView(fileName: "BeerBottle")
                .frame(width: 140, height: 150)
            
            Spacer()
            
            // Start button
            Button {
                startCalibration()
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
    
    func startCalibration() {
        currentState = .calibrating
        
        // Ini nanti kondisi perlu waktu berapa lama pas calibrating
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            currentState = .allSet
            
            // Ini kalo udah selesai calibrating
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isMonitoring = true
            }
        }
    }
}

#Preview("Start") {
    StartView(isMonitoring: .constant(false))
}

//
//  SafetyCheckView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 10/07/26.
//

import SwiftUI

struct SafetyCheckView: View {
    @Binding var isPresented: Bool
    
    @State var showEmergency = false
    @State var showDrunkAlarm = false
    @State var responseTimer: Timer?
    
    // TODO: Replace with configurable timeout from settings
    let responseTimeout: TimeInterval = 15
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Text("Are you drunk?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // I'm Fine — dismiss safety check, return to SoberScoreView
                Button {
                    stopResponseTimer()
                    isPresented = false
                } label: {
                    Text("I'm Fine")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.00, green: 0.90, blue: 0.30))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                // Get Help — show emergency countdown
                Button {
                    stopResponseTimer()
                    showEmergency = true
                } label: {
                    Text("Get Help")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(white: 0.28))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden)
        .onAppear {
            startResponseTimer()
        }
        .onDisappear {
            stopResponseTimer()
        }
        // No response timeout → DrunkAlarm
        .fullScreenCover(isPresented: $showDrunkAlarm) {
            DrunkAlarmView(isPresented: $showDrunkAlarm)
        }
        // Direct "Get Help" → Emergency
        .fullScreenCover(isPresented: $showEmergency) {
            EmergencyCountdownView(isPresented: $showEmergency)
        }
        // When DrunkAlarm is dismissed (user muted or emergency cancelled), also dismiss SafetyCheck
        .onChange(of: showDrunkAlarm) { oldValue, newValue in
            if oldValue == true && newValue == false {
                isPresented = false
            }
        }
        // Emergency cancelled from "Get Help" → also dismiss SafetyCheck → back to SoberScoreView
        .onChange(of: showEmergency) { oldValue, newValue in
            if oldValue == true && newValue == false {
                isPresented = false
            }
        }
    }
    
    // MARK: - No-Response Timer
    
    func startResponseTimer() {
        // TODO: Replace with actual sober level monitoring / inactivity detection
        responseTimer = Timer.scheduledTimer(withTimeInterval: responseTimeout, repeats: false) { _ in
            showDrunkAlarm = true
        }
    }
    
    func stopResponseTimer() {
        responseTimer?.invalidate()
        responseTimer = nil
    }
}

#Preview("Safety Check") {
    SafetyCheckView(isPresented: .constant(true))
}

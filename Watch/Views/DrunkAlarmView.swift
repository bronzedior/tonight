//
//  DrunkAlarmView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 10/07/26.
//

import SwiftUI
import WatchKit

struct DrunkAlarmView: View {
    @Binding var isPresented: Bool
    
    let alarmRed = Color(red: 0.95, green: 0.25, blue: 0.25)
    let holdDuration: CGFloat = 3.0     // seconds to hold for mute
    let alarmTimeout: Int = 15          // seconds before auto-emergency
    
    @State var holdProgress: CGFloat = 0
    @State var isHolding = false
    @State var holdTimer: Timer?
    @State var alarmCountdown: Int = 15
    @State var alarmTimer: Timer?
    @State var showEmergency = false

    /// Timer yang mainin haptic berulang biar terasa "nyala terus".
    @State var hapticTimer: Timer?
    /// Jeda antar getaran (detik).
    let hapticInterval: TimeInterval = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // DRUNK label
                Text("DRUNK")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(alarmRed)
                
                // Hold-to-mute button
                ZStack {
                    // Track circle (dimmed)
                    Circle()
                        .stroke(alarmRed.opacity(0.3), lineWidth: 3)
                        .frame(width: 80, height: 80)
                    
                    // Progress arc (fills while holding)
                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(alarmRed, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    // Tap/hand icon
                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(alarmRed)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isHolding {
                                isHolding = true
                                startHold()
                            }
                        }
                        .onEnded { _ in
                            isHolding = false
                            cancelHold()
                        }
                )
                
                Text("Hold to Mute")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .toolbar(.hidden)
        .onAppear {
            alarmCountdown = alarmTimeout
            startAlarmTimer()
            startHaptics()
            // TODO: Play alarm sound
        }
        .onDisappear {
            stopAlarmTimer()
            stopHoldTimer()
            stopHaptics()
        }
        .fullScreenCover(isPresented: $showEmergency) {
            EmergencyCountdownView(isPresented: $showEmergency)
        }
        // Emergency cancelled → dismiss alarm → cascades to SafetyCheck → back to SoberScoreView
        .onChange(of: showEmergency) { oldValue, newValue in
            if oldValue == true && newValue == false {
                isPresented = false
            }
        }
    }
    
    // MARK: - Hold-to-Mute
    
    func startHold() {
        holdProgress = 0
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            holdProgress += 0.05 / holdDuration
            if holdProgress >= 1.0 {
                // Successfully muted
                stopHoldTimer()
                stopAlarmTimer()
                stopHaptics()
                isPresented = false
            }
        }
    }
    
    func cancelHold() {
        stopHoldTimer()
        withAnimation(.easeOut(duration: 0.3)) {
            holdProgress = 0
        }
    }
    
    func stopHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = nil
    }
    
    // MARK: - Alarm Timeout → Emergency
    
    func startAlarmTimer() {
        alarmTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            alarmCountdown -= 1
            if alarmCountdown <= 0 {
                stopAlarmTimer()
                stopHaptics()          // berhenti biar nggak getar di balik layar Emergency
                // No response — redirect to emergency
                showEmergency = true
            }
        }
    }
    
    func stopAlarmTimer() {
        alarmTimer?.invalidate()
        alarmTimer = nil
    }

    // MARK: - Continuous Haptic

    /// Mulai getaran berulang biar alarm terasa terus-menerus.
    /// watchOS nggak punya haptic "continuous", jadi kita ulang pola pendek
    /// tiap `hapticInterval`.
    func startHaptics() {
        stopHaptics()                       // jaga-jaga biar nggak dobel timer
        WKInterfaceDevice.current().play(.notification)
        hapticTimer = Timer.scheduledTimer(withTimeInterval: hapticInterval, repeats: true) { _ in
            WKInterfaceDevice.current().play(.notification)
        }
    }

    func stopHaptics() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}

#Preview("Drunk Alarm") {
    DrunkAlarmView(isPresented: .constant(true))
}

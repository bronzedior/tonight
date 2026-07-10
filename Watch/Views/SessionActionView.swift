//
//  SessionActionView.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 10/07/26.
//

import SwiftUI

struct SessionActionView: View {
    @Binding var isMonitoring: Bool
    @Binding var activeTab: Int
    
    @State var showEndSession = false
    @State var showEmergency = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top row: status label (matches SoberScoreView)
            HStack(alignment: .top) {
                Spacer()
                Text("Status")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white)
            }
            .padding(.top, -18)
            
            Spacer()
            
            // Center: Finish & Emergency buttons
            HStack(spacing: 12) {
                // Finish button
                Button {
                    showEndSession = true
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Capsule()
                                .fill(Color(red: 0.35, green: 0.10, blue: 0.10))
                                .frame(height: 56)
                            
                            Image(systemName: "stop.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(red: 0.85, green: 0.20, blue: 0.20))
                        }
                        
                        Text("Finish")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                
                // Emergency button
                Button {
                    showEmergency = true
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Capsule()
                                .fill(Color(white: 0.22))
                                .frame(height: 56)
                            
                            Image(systemName: "phone.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.orange)
                        }
                        
                        Text("Emergency")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .containerBackground(.black, for: .tabView)
        .fullScreenCover(isPresented: $showEndSession) {
            EndSessionConfirmView(isMonitoring: $isMonitoring, isPresented: $showEndSession)
        }
        .fullScreenCover(isPresented: $showEmergency) {
            EmergencyCountdownView(isPresented: $showEmergency)
        }
        // Emergency cancelled → switch to SoberScoreView
        .onChange(of: showEmergency) { oldValue, newValue in
            if oldValue == true && newValue == false {
                activeTab = 1
            }
        }
    }
}

// MARK: - End Session Confirmation

struct EndSessionConfirmView: View {
    @Binding var isMonitoring: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Text("Done drinking?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Nope button — dismiss sheet
                Button {
                    isPresented = false
                } label: {
                    Text("Nope")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(white: 0.28))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                // Stop Tracking button — ends session
                Button {
                    // TODO: Save session data before ending
                    isPresented = false
                    isMonitoring = false
                } label: {
                    Text("Stop Tracking")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.20, blue: 0.20))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.30, green: 0.08, blue: 0.08))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden)
    }
}

// MARK: - Emergency Countdown

struct EmergencyCountdownView: View {
    @Binding var isPresented: Bool
    
    // TODO: Replace with actual emergency contact name from user settings
    let contactName: String = "Donny"
    
    @State var countdown: Int = 10
    @State var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)
                
                // "Calling Donny in" with bold contact name
                Text({
                    let a = AttributedString("Calling ")
                    var name = AttributedString(contactName)
                    name.inlinePresentationIntent = .stronglyEmphasized
                    let tail = AttributedString(" in")
                    var combined = a
                    combined.append(name)
                    combined.append(tail)
                    return combined
                }())
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                
                // Countdown number
                Text("\(countdown)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                
                // Cancel button
                Button {
                    stopCountdown()
                    isPresented = false
                } label: {
                    Text("Cancel")
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
            startCountdown()
        }
        .onDisappear {
            stopCountdown()
        }
    }
    
    func startCountdown() {
        countdown = 10
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                withAnimation {
                    countdown -= 1
                }
            }
            if countdown == 0 {
                stopCountdown()
                // TODO: Trigger actual phone call / send alert to emergency contact
                // TODO: Dismiss view after call is initiated
            }
        }
    }
    
    func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Previews

#Preview("Session Actions") {
    SessionActionView(isMonitoring: .constant(true), activeTab: .constant(0))
}

#Preview("End Session") {
    EndSessionConfirmView(isMonitoring: .constant(true), isPresented: .constant(true))
}

#Preview("Emergency Countdown") {
    EmergencyCountdownView(isPresented: .constant(true))
}


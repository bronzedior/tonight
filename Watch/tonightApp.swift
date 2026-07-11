//
//  tonight_watchApp.swift
//  tonight watch Watch App
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI
import Combine

@main
struct tonightWatchApp: App {
    @StateObject var dataProvider = DummyDataProvider()
    @State var isMonitoring = false
    
    @State var activeTab = 1
    @State var showSafetyCheck = false
    
    var body: some Scene {
        WindowGroup {
            if isMonitoring {
                TabView {
                    TabView(selection: $activeTab) {
                        SessionActionView(isMonitoring: $isMonitoring, activeTab: $activeTab)
                            .tag(0)
                        
                        SoberScoreView(score: dataProvider.soberScore, date: dataProvider.currentDate,
                                       heartRate: Int(dataProvider.averageHeartRate),
                                       gaitScore: Int(dataProvider.averageGaitStability))
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
                .tabViewStyle(.verticalPage)
                .transition(.opacity)
                .fullScreenCover(isPresented: $showSafetyCheck) {
                    SafetyCheckView(isPresented: $showSafetyCheck)
                }
                .onAppear {
                    // TODO: Replace with actual sober level monitoring logic
                    // e.g. trigger when SoberLevel drops to .drunk or stays .drunk for X minutes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                        if isMonitoring {
                            showSafetyCheck = true
                        }
                    }
                }
            } else {
                StartView(isMonitoring: $isMonitoring)
                    .onAppear {
                        activeTab = 1
                        showSafetyCheck = false
                    }
            }
        }
    }
}

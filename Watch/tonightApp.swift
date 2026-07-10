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
    
    var body: some Scene {
        WindowGroup {
            if isMonitoring {
                TabView {
                    SoberScoreView(score: dataProvider.soberScore, date: dataProvider.currentDate,
                                   isMonitoring: $isMonitoring)
                    TabView {
                        HeartRateChartView(readings: dataProvider.heartRateReadings,
                                           isMonitoring: $isMonitoring)
                        BodyGaitChartView(readings: dataProvider.gaitReadings,
                                          isMonitoring: $isMonitoring)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
                .tabViewStyle(.verticalPage)
                .transition(.opacity)
            } else {
                StartView(isMonitoring: $isMonitoring)
            }
        }
    }
}

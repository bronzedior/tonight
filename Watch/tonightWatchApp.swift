//
//  tonightWatchApp.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 04/07/26.
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
                    HeartRateChartView(readings: dataProvider.heartRateReadings,
                                       isMonitoring: $isMonitoring)
                    BodyGaitChartView(readings: dataProvider.gaitReadings,
                                      isMonitoring: $isMonitoring)
                }
                .tabViewStyle(.verticalPage)
                .transition(.opacity)
            } else {
                StartView(isMonitoring: $isMonitoring)
            }
        }
    }
}

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
    @StateObject var viewModel = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            if viewModel.isMonitoring {
                if viewModel.baselinePhase == .collecting {
                    // Fase baseline: tampilkan progress pengumpulan data
                    BaselineView(viewModel: viewModel)
                } else {
                    // Fase deteksi: tampilkan score, HR chart, gait chart
                    TabView {
                        SoberScoreView(viewModel: viewModel)
                        HeartRateChartView(viewModel: viewModel)
                        BodyGaitChartView(viewModel: viewModel)
                    }
                    .tabViewStyle(.verticalPage)
                    .transition(.opacity)
                }
            } else {
                StartView(viewModel: viewModel)
            }
        }
    }
}

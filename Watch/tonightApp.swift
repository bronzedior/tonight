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
    /// Sumber kebenaran realtime: HR + CoreMotion + RiskScoringEngine.
    @StateObject var viewModel = SessionViewModel()

    @State var activeTab = 1
    @State var showSafetyCheck = false
    /// Tampilkan checkmark "All Set" sebentar begitu kalibrasi selesai.
    @State var showAllSet = false

    var body: some Scene {
        WindowGroup {
            content
                .onChange(of: viewModel.baselinePhase) { _, phase in
                    switch phase {
                    case .established:
                        // Kalibrasi selesai → checkmark sebentar, lalu dashboard.
                        activeTab = 1
                        showAllSet = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            showAllSet = false
                        }
                    case .idle:
                        showSafetyCheck = false
                        showAllSet = false
                    case .collecting:
                        break
                    }
                }
                // Trigger safety check dari level mabuk sungguhan, bukan timer dummy.
                .onChange(of: viewModel.currentLevel) { _, level in
                    if level == .drunk, !showSafetyCheck, viewModel.baselinePhase == .established {
                        showSafetyCheck = true
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.baselinePhase {
        case .idle:
            StartView(viewModel: viewModel)

        case .collecting:
            CalibratingView()

        case .established:
            if showAllSet {
                AllSetView()
            } else {
                monitoringView
            }
        }
    }

    private var monitoringView: some View {
        TabView {
            TabView(selection: $activeTab) {
                SessionActionView(
                    isMonitoring: $viewModel.isMonitoring,
                    activeTab: $activeTab,
                    onEnd: { viewModel.stopSession() }
                )
                .tag(0)

                SoberScoreView(
                    score: viewModel.soberScore,
                    date: viewModel.sessionDate,
                    heartRate: Int(viewModel.latestHeartRate.rounded()),
                    gaitScore: Int((viewModel.gaitReadings.last?.stability ?? 100).rounded())
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .tabViewStyle(.verticalPage)
        .transition(.opacity)
        .fullScreenCover(isPresented: $showSafetyCheck) {
            SafetyCheckView(isPresented: $showSafetyCheck)
        }
    }
}

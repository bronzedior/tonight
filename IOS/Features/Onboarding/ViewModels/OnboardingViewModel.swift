//
//  OnboardingViewModel.swift
//  tonight
//
//  Created by Yuki Damanik on 03/07/26.
//

import Foundation
import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var username = ""
    
    @Published var watchConnected = false
    @Published var healthPermissionGranted = false
    
    @Published var showPermissionDenied = false
    
    func next() {
        guard currentStep < 4 else {return }
        currentStep += 1
    }
    
    func previous() {
        guard currentStep > 0 else {return }
        currentStep -= 1
    }
    
    func finish() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

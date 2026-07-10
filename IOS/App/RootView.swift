//
//  ContentView.swift
//  tonight
//
//  Created by Yuki Damanik on 02/07/26.
//

import SwiftUI

struct RootView: View {
    
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            Text("Home")
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    RootView()
}
    

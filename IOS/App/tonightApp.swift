//
//  tonightApp.swift
//  tonight
//
//  Created by Yuki Damanik on 02/07/26.
//

import SwiftUI

@main
struct tonightApp: App {
    @StateObject private var sessionSync = SessionSyncManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

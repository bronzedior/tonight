//
//  CloseSessionModifier.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 04/07/26.
//

import SwiftUI

struct CloseSessionModifier: ViewModifier {
    @Binding var isMonitoring: Bool
    var onEndSession: (() -> Void)?
    @State var showEndSession = false

    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            content
                .frame(maxWidth: .infinity)

            Button { showEndSession = true } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(white: 0.25))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .alert("End Session?", isPresented: $showEndSession) {
            Button("Cancel", role: .cancel) { }
            Button("End Session", role: .destructive) {
                onEndSession?()
                isMonitoring = false
            }
        } message: {
            Text("This activity will be saved in your phone. You can edit it later.")
        }
    }
}

extension View {
    func closeSession(isMonitoring: Binding<Bool>, onEnd: (() -> Void)? = nil) -> some View {
        modifier(CloseSessionModifier(isMonitoring: isMonitoring, onEndSession: onEnd))
    }
}

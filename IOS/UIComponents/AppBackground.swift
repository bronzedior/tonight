//
//  AppBackground.swift
//  tonight
//
//  Created by Yuki Damanik on 06/07/26.
//

import SwiftUI

struct AppBackground: View {

    var body: some View {

        ZStack {

            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(x: 0.0, y: 0.0),
                    .init(x: 0.5, y: 0.0),
                    .init(x: 1.0, y: 0.0),

                    .init(x: 0.0, y: 0.5),
                    .init(x: 0.5, y: 0.5),
                    .init(x: 1.0, y: 0.5),

                    .init(x: 0.0, y: 1.0),
                    .init(x: 0.5, y: 1.0),
                    .init(x: 1.0, y: 1.0)
                ],
                colors: [
                    Color(red: 0.15, green: 0.34, blue: 0.96),
                    Color(red: 0.32, green: 0.52, blue: 1.00),
                    Color.white.opacity(0.95),

                    Color(red: 0.10, green: 0.18, blue: 0.45),
                    Color(red: 0.07, green: 0.11, blue: 0.30),
                    Color(red: 0.05, green: 0.08, blue: 0.22),

                    Color.black,
                    Color.black,
                    Color.black
                ]
            )

            // Overlay untuk menggelapkan bagian bawah
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.00),
                    .init(color: .clear, location: 0.30),
                    .init(color: Color.black.opacity(0.25), location: 0.55),
                    .init(color: Color.black.opacity(0.75), location: 0.75),
                    .init(color: .black, location: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        }
        .ignoresSafeArea()
    }
}

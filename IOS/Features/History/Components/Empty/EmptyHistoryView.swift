//
//  EmptyHistoryView.swift
//  tonight
//
//  Created by Yuki Damanik on 08/07/26.
//

import SwiftUI

struct EmptyHistoryView: View {

    var body: some View {

        VStack(spacing: 24) {

            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundStyle(.gray)

            VStack(spacing: 8) {

                Text("No Sessions Yet")
                    .font(.title3)
                    .bold()

                Text("Create a record by starting a monitoring session on TipSee Watch.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

            }

            Spacer()

        }
        .padding()

    }

}

#Preview {
    EmptyHistoryView()
}

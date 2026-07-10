//
//  CalibratingModifier.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 09/07/26.
//

import SwiftUI

struct CalibratingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()
            
            Text("Calibrating..")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Designed for approximate tracking, not clinical precision.")
                .font(.system(size: 12))
                .foregroundStyle(.gray)
                .lineLimit(nil)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.black)
    }
}

#Preview {
    CalibratingView()
}

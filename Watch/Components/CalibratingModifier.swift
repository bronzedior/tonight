//
//  CalibratingModifier.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 09/07/26.
//

import SwiftUI

struct CalibratingView: View {
    // Fun facts to display during calibration
    let funFacts = [
        "Diet soda actually makes you get drunk faster than regular soda.",
        "The average person metabolizes one standard drink per hour.",
        "Alcohol can affect your balance within just 10 minutes of consumption.",
        "Your body treats alcohol as a toxin and prioritizes processing it.",
        "Drinking water between drinks can help slow alcohol absorption."
    ]
    
    @State var currentFact: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()
            
            Text("Calibrating..")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Text(currentFact)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.gray)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.black)
        .onAppear {
            currentFact = funFacts.randomElement() ?? funFacts[0]
        }
    }
}

#Preview {
    CalibratingView()
}

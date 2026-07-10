//
//  InfoSheet.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 10/07/26.
//

import SwiftUI

struct InfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    let soberLevel: SoberLevel
    let timeRange: String
    let hrRange: String
    let stability: String
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 35, height: 35)
                            .background(Color(white: 0.25))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
//                    .frame(width: 35, height: 35)
                    .offset(y: -10)
                    
                    Spacer()
                    
                    Text("More Info")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(soberLevel.rawValue)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(soberLevel.color)
                            
                            Text(timeRange)
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                        
                        Divider()
                            .foregroundStyle(.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Heart Rate")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(hrRange)
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                        
                        Divider()
                            .foregroundStyle(.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Body Stability")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text(stability)
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                        
                        Divider()
                            .foregroundStyle(.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("How Your Condition Is Measured")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("Your impairment score is estimated by comparing changes in your heart rate and body stability with your personal baseline. This score reflects how your body responds overtime and is intended for awareness, not as a medical or legal measurement.")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    .padding(.horizontal, 8)
                    .padding(.bottom, 16)
                }
                
            }
            .padding(.horizontal, 4)
            .offset(y: -33)
        }
        .containerBackground(.black, for: .tabView)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    InfoSheetView(
        soberLevel: .drunk,
        timeRange: "21.39-02.34",
        hrRange: "90-140 BPM",
        stability: "70%"
    )
}

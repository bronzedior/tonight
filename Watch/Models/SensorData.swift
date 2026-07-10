//
//  SensorData.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import SwiftUI
import Combine

struct HeartRateReading: Identifiable {
    let id = UUID()
    let minuteOffset: Int
    let bpmLow: Int
    let bpmHigh: Int
}

struct GaitReading: Identifiable {
    let id = UUID()
    let minuteOffset: Int
    let stability: Double
}

enum SoberLevel: String {
    case sober = "SOBER"
    case ok = "OK"
    case tipsy = "TIPSY"
    case drunk = "DRUNK"
    
    static func from(score: Int) -> SoberLevel {
        switch score {
        case 80...100: return .sober
        case 60..<80:  return .ok
        case 40..<60:  return .tipsy
        default:       return .drunk
        }
    }
    
    var color: Color {
        switch self {
        case .sober:     return Color(red: 0.00, green: 0.90, blue: 0.30)
        case .ok:        return Color(red: 0.00, green: 0.90, blue: 0.80)
        case .tipsy:    return Color(red: 0.85, green: 0.60, blue: 0.00)
        case .drunk:     return Color(red: 0.83, green: 0.18, blue: 0.18)
        }
    }
    
    var subtitle: String {
        switch self {
        case .sober: return "Way to go"
        case .ok:    return "Doing fine"
        case .tipsy: return "Take it easy"
        case .drunk: return "Be careful"
        }
    }
}

// MARK: - Dummy Data nanti diganti kalo udah connect real time
class DummyDataProvider: ObservableObject {
    static let shared = DummyDataProvider()
    
    let heartRateReadings: [HeartRateReading] = [
        HeartRateReading(minuteOffset:  0, bpmLow:  95, bpmHigh: 110),
        HeartRateReading(minuteOffset:  1, bpmLow: 100, bpmHigh: 115),
        HeartRateReading(minuteOffset:  2, bpmLow: 110, bpmHigh: 125),
        HeartRateReading(minuteOffset:  3, bpmLow: 102, bpmHigh: 116),
        HeartRateReading(minuteOffset:  4, bpmLow: 118, bpmHigh: 135),
        HeartRateReading(minuteOffset:  5, bpmLow:  92, bpmHigh: 106),
        HeartRateReading(minuteOffset:  6, bpmLow: 100, bpmHigh: 116),
        HeartRateReading(minuteOffset:  7, bpmLow:  90, bpmHigh: 104),
        HeartRateReading(minuteOffset:  8, bpmLow:  90, bpmHigh: 104),
        HeartRateReading(minuteOffset:  9, bpmLow:  95, bpmHigh: 106),
        HeartRateReading(minuteOffset: 10, bpmLow:  90, bpmHigh: 104),
        HeartRateReading(minuteOffset: 11, bpmLow:  96, bpmHigh: 110),
        HeartRateReading(minuteOffset: 12, bpmLow:  90, bpmHigh: 104),
        HeartRateReading(minuteOffset: 13, bpmLow: 104, bpmHigh: 118),
        HeartRateReading(minuteOffset: 14, bpmLow:  96, bpmHigh: 108),
        HeartRateReading(minuteOffset: 15, bpmLow: 108, bpmHigh: 122),
        HeartRateReading(minuteOffset: 16, bpmLow:  98, bpmHigh: 110),
        HeartRateReading(minuteOffset: 17, bpmLow: 112, bpmHigh: 126),
        HeartRateReading(minuteOffset: 18, bpmLow: 104, bpmHigh: 118),
        HeartRateReading(minuteOffset: 19, bpmLow:  94, bpmHigh: 106),
        HeartRateReading(minuteOffset: 20, bpmLow: 108, bpmHigh: 122),
        HeartRateReading(minuteOffset: 21, bpmLow: 116, bpmHigh: 130),
        HeartRateReading(minuteOffset: 22, bpmLow: 106, bpmHigh: 120),
        HeartRateReading(minuteOffset: 23, bpmLow: 118, bpmHigh: 134),
        HeartRateReading(minuteOffset: 24, bpmLow: 122, bpmHigh: 140),
        HeartRateReading(minuteOffset: 25, bpmLow: 112, bpmHigh: 124),
        HeartRateReading(minuteOffset: 26, bpmLow: 116, bpmHigh: 132),
        HeartRateReading(minuteOffset: 27, bpmLow: 102, bpmHigh: 116),
        HeartRateReading(minuteOffset: 28, bpmLow: 114, bpmHigh: 128),
        HeartRateReading(minuteOffset: 29, bpmLow: 124, bpmHigh: 138),
        HeartRateReading(minuteOffset: 30, bpmLow: 118, bpmHigh: 134),
        HeartRateReading(minuteOffset: 31, bpmLow: 122, bpmHigh: 138),
        HeartRateReading(minuteOffset: 32, bpmLow: 112, bpmHigh: 128),
        HeartRateReading(minuteOffset: 33, bpmLow: 120, bpmHigh: 135),
        HeartRateReading(minuteOffset: 34, bpmLow: 114, bpmHigh: 132),
        HeartRateReading(minuteOffset: 35, bpmLow: 102, bpmHigh: 118),
    ]
    
    let gaitReadings: [GaitReading] = [
        GaitReading(minuteOffset:  0, stability: 3.0),
        GaitReading(minuteOffset:  6, stability: 2.2),
        GaitReading(minuteOffset: 12, stability: 1.8),
        GaitReading(minuteOffset: 20, stability: 1.9),
        GaitReading(minuteOffset: 26, stability: 2.5),
        GaitReading(minuteOffset: 32, stability: 1.5),
    ]
    
    var averageHeartRate: Double {
        guard !heartRateReadings.isEmpty else { return 0 }
        let total = heartRateReadings.reduce(0.0) { $0 + Double($1.bpmLow + $1.bpmHigh) / 2.0 }
        return total / Double(heartRateReadings.count)
        
    }
    var averageGaitStability: Double {
        // Nanti dihitung lagi
        return 67.83
    }
    
    var soberScore: Int {
        // Nanti dihitung lagi
        return 35
    }
    var currentDate: Date { Date() }
}

//
//  SensorData.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 04/07/26.
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
    case semiDrunk = "SEMI-DRUNK"
    case drunk = "DRUNK"
    
    static func from(score: Int) -> SoberLevel {
        switch score {
        case 80...100: return .sober
        case 60..<80:  return .ok
        case 40..<60:  return .semiDrunk
        default:       return .drunk
        }
    }
    
    var color: Color {
        switch self {
        case .sober:     return Color(red: 0.00, green: 0.90, blue: 0.30)
        case .ok:        return Color(red: 0.00, green: 0.90, blue: 0.80)
        case .semiDrunk: return Color(red: 0.85, green: 0.60, blue: 0.00)
        case .drunk:     return Color(red: 0.83, green: 0.18, blue: 0.18)
        }
    }
}

// MARK: - Dummy Data nanti diganti kalo udah connect real time
// class DummyDataProvider: ObservableObject {
//     static let shared = DummyDataProvider()
    
//     let heartRateReadings: [HeartRateReading] = [
//         HeartRateReading(minuteOffset:  0, bpmLow:  90, bpmHigh: 105),
//         HeartRateReading(minuteOffset:  1, bpmLow:  95, bpmHigh: 110),
//         HeartRateReading(minuteOffset:  2, bpmLow: 100, bpmHigh: 118),
//         HeartRateReading(minuteOffset:  3, bpmLow:  92, bpmHigh: 106),
//         HeartRateReading(minuteOffset:  4, bpmLow: 108, bpmHigh: 125),
//         HeartRateReading(minuteOffset:  5, bpmLow:  82, bpmHigh:  96),
//         HeartRateReading(minuteOffset:  6, bpmLow:  90, bpmHigh: 106),
//         HeartRateReading(minuteOffset:  7, bpmLow:  70, bpmHigh:  84),
//         HeartRateReading(minuteOffset:  8, bpmLow:  80, bpmHigh:  94),
//         HeartRateReading(minuteOffset:  9, bpmLow:  75, bpmHigh:  86),
//         HeartRateReading(minuteOffset: 10, bpmLow:  60, bpmHigh:  74),
//         HeartRateReading(minuteOffset: 11, bpmLow:  76, bpmHigh:  90),
//         HeartRateReading(minuteOffset: 12, bpmLow:  70, bpmHigh:  84),
//         HeartRateReading(minuteOffset: 13, bpmLow:  84, bpmHigh:  98),
//         HeartRateReading(minuteOffset: 14, bpmLow:  66, bpmHigh:  78),
//         HeartRateReading(minuteOffset: 15, bpmLow:  78, bpmHigh:  92),
//         HeartRateReading(minuteOffset: 16, bpmLow:  68, bpmHigh:  80),
//         HeartRateReading(minuteOffset: 17, bpmLow:  82, bpmHigh:  96),
//         HeartRateReading(minuteOffset: 18, bpmLow:  74, bpmHigh:  88),
//         HeartRateReading(minuteOffset: 19, bpmLow:  64, bpmHigh:  76),
//         HeartRateReading(minuteOffset: 20, bpmLow:  78, bpmHigh:  92),
//         HeartRateReading(minuteOffset: 21, bpmLow:  86, bpmHigh: 100),
//         HeartRateReading(minuteOffset: 22, bpmLow:  76, bpmHigh:  90),
//         HeartRateReading(minuteOffset: 23, bpmLow:  88, bpmHigh: 104),
//         HeartRateReading(minuteOffset: 24, bpmLow:  92, bpmHigh: 108),
//         HeartRateReading(minuteOffset: 25, bpmLow:  82, bpmHigh:  94),
//         HeartRateReading(minuteOffset: 26, bpmLow:  86, bpmHigh: 102),
//         HeartRateReading(minuteOffset: 27, bpmLow:  72, bpmHigh:  86),
//         HeartRateReading(minuteOffset: 28, bpmLow:  84, bpmHigh:  98),
//         HeartRateReading(minuteOffset: 29, bpmLow:  94, bpmHigh: 112),
//         HeartRateReading(minuteOffset: 30, bpmLow:  88, bpmHigh: 104),
//         HeartRateReading(minuteOffset: 31, bpmLow:  98, bpmHigh: 118),
//         HeartRateReading(minuteOffset: 32, bpmLow:  92, bpmHigh: 108),
//         HeartRateReading(minuteOffset: 33, bpmLow: 100, bpmHigh: 120),
//         HeartRateReading(minuteOffset: 34, bpmLow:  94, bpmHigh: 112),
//         HeartRateReading(minuteOffset: 35, bpmLow:  82, bpmHigh:  98),
//     ]

//     let gaitReadings: [GaitReading] = [
//         GaitReading(minuteOffset:  0, stability: 3.0),
//         GaitReading(minuteOffset:  6, stability: 2.2),
//         GaitReading(minuteOffset: 12, stability: 1.8),
//         GaitReading(minuteOffset: 20, stability: 1.9),
//         GaitReading(minuteOffset: 26, stability: 2.5),
//         GaitReading(minuteOffset: 32, stability: 1.5),
//     ]

//     var averageHeartRate: Double {
//         guard !heartRateReadings.isEmpty else { return 0 }
//         let total = heartRateReadings.reduce(0.0) { $0 + Double($1.bpmLow + $1.bpmHigh) / 2.0 }
//         return total / Double(heartRateReadings.count)
        
//     }
//     var averageGaitStability: Double {
//         guard !gaitReadings.isEmpty else { return 0 }
//         let total = gaitReadings.reduce(0.0) { $0 + $1.stability }
//         return total / Double(gaitReadings.count)
//     }
    
//     var soberScore: Int {
//         let hrScore   = max(0.0, min(100.0, 100.0 - (averageHeartRate - 60.0) * 0.8))
//         let gaitScore = averageGaitStability
//         let combined  = (hrScore * 0.4) + (gaitScore * 0.6)
//         return min(100, max(0, Int(combined.rounded())))
//     }
//     var currentDate: Date { Date() }
// }

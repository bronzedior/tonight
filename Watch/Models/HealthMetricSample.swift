//
//  HealthMetricSample.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 07/07/26.
//

import Foundation

struct HealthMetricSample: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Double           
    let walkingSpeed: Double?       
    let walkingAsymmetry: Double?  
    let doubleSupportTime: Double? 
}

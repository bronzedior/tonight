//
//  SessionTransfer.swift
//  tonight

import Foundation

struct SessionTransfer: Codable {

    //hr per menit
    struct HeartRateInterval: Codable {
        let start: Date
        let end: Date
        let minBPM: Double
        let maxBPM: Double
    }

    struct GaitPoint: Codable {
        let timestamp: Date
        let score: Double
    }

    struct TimelineSegment: Codable {
        let start: Date
        let end: Date
        let impairmentScore: Double
        let level: String
    }

    let id: UUID
    let startDate: Date
    let endDate: Date

    let peakImpairmentScore: Double
    let peakLevel: String

    let averageHeartRate: Double
    let averageStability: Double

    let heartRateSamples: [HeartRateInterval]
    let bodyGaitSamples: [GaitPoint]
    let timeline: [TimelineSegment]
}

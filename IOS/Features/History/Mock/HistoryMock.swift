//
//  HistoryMock.swift
//  tonight
//
//  Created by Yuki Damanik on 08/07/26.
//

import Foundation

enum HistoryMock {

    static let previewHeartRateSamples:
        [HeartRateSample] = {
            let startDate =
                makeSessionStartDate(
                    daysAgo: 0
                )

            return makeHeartRateSamples(
                startDate: startDate
            )
        }()

    static let previewBodyGaitSamples:
        [BodyGaitSample] = {
            let startDate =
                makeSessionStartDate(
                    daysAgo: 0
                )

            return makeBodyGaitSamples(
                startDate: startDate
            )
        }()

    static let sessions: [SessionHistory] = [
        makeSession(
            daysAgo: 0,
            peakLevel: .drunk,
            peakScore: 86,
            averageHeartRate: 142,
            averageStability: 72
        ),

        makeSession(
            daysAgo: 1,
            peakLevel: .tipsy,
            peakScore: 64,
            averageHeartRate: 118,
            averageStability: 81
        ),

        makeSession(
            daysAgo: 3,
            peakLevel: .ok,
            peakScore: 42,
            averageHeartRate: 98,
            averageStability: 90
        ),

        makeSession(
            daysAgo: 7,
            peakLevel: .sober,
            peakScore: 18,
            averageHeartRate: 84,
            averageStability: 96
        )
    ]
}

// MARK: - Session

private extension HistoryMock {

    static func makeSession(
        daysAgo: Int,
        peakLevel: ImpairmentLevel,
        peakScore: Double,
        averageHeartRate: Double,
        averageStability: Double
    ) -> SessionHistory {
        let startDate =
            makeSessionStartDate(
                daysAgo: daysAgo
            )

        let endDate =
            startDate.addingTimeInterval(
                160 * 60
            )

        return SessionHistory(
            startDate: startDate,
            endDate: endDate,
            peakLevel: peakLevel,
            peakScore: peakScore,
            averageHeartRate:
                averageHeartRate,
            averageStability:
                averageStability,
            timeline: makeTimeline(
                startDate: startDate,
                peakLevel: peakLevel
            ),
            heartRateSamples:
                makeHeartRateSamples(
                    startDate: startDate
                ),
            bodyGaitSamples:
                makeBodyGaitSamples(
                    startDate: startDate
                )
        )
    }

    static func makeSessionStartDate(
        daysAgo: Int
    ) -> Date {
        let calendar = Calendar.current

        let today =
            calendar.startOfDay(for: Date())

        let sessionDay =
            calendar.date(
                byAdding: .day,
                value: -daysAgo,
                to: today
            )
            ?? today

        return calendar.date(
            bySettingHour: 10,
            minute: 0,
            second: 0,
            of: sessionDay
        )
        ?? sessionDay
    }
}

// MARK: - Timeline Mock

private extension HistoryMock {

    static func makeTimeline(
        startDate: Date,
        peakLevel: ImpairmentLevel
    ) -> [TimelinePoint] {
        switch peakLevel {

        case .drunk:
            return drunkTimeline(
                startDate: startDate
            )

        case .tipsy:
            return tipsyTimeline(
                startDate: startDate
            )

        case .ok:
            return okTimeline(
                startDate: startDate
            )

        case .sober:
            return soberTimeline(
                startDate: startDate
            )
        }
    }

    static func drunkTimeline(
        startDate: Date
    ) -> [TimelinePoint] {
        [
            timelinePoint(
                startDate: startDate,
                startMinute: 0,
                endMinute: 20,
                score: 12,
                level: .sober
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 20,
                endMinute: 30,
                score: 34,
                level: .ok
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 30,
                endMinute: 40,
                score: 18,
                level: .sober
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 40,
                endMinute: 50,
                score: 38,
                level: .ok
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 50,
                endMinute: 70,
                score: 20,
                level: .sober
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 70,
                endMinute: 100,
                score: 62,
                level: .tipsy
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 100,
                endMinute: 160,
                score: 86,
                level: .drunk
            )
        ]
    }

    static func tipsyTimeline(
        startDate: Date
    ) -> [TimelinePoint] {
        [
            timelinePoint(
                startDate: startDate,
                startMinute: 0,
                endMinute: 40,
                score: 14,
                level: .sober
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 40,
                endMinute: 85,
                score: 37,
                level: .ok
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 85,
                endMinute: 160,
                score: 64,
                level: .tipsy
            )
        ]
    }

    static func okTimeline(
        startDate: Date
    ) -> [TimelinePoint] {
        [
            timelinePoint(
                startDate: startDate,
                startMinute: 0,
                endMinute: 70,
                score: 16,
                level: .sober
            ),

            timelinePoint(
                startDate: startDate,
                startMinute: 70,
                endMinute: 160,
                score: 42,
                level: .ok
            )
        ]
    }

    static func soberTimeline(
        startDate: Date
    ) -> [TimelinePoint] {
        [
            timelinePoint(
                startDate: startDate,
                startMinute: 0,
                endMinute: 160,
                score: 18,
                level: .sober
            )
        ]
    }

    static func timelinePoint(
        startDate: Date,
        startMinute: Int,
        endMinute: Int,
        score: Double,
        level: ImpairmentLevel
    ) -> TimelinePoint {
        TimelinePoint(
            startDate:
                startDate.addingTimeInterval(
                    TimeInterval(
                        startMinute * 60
                    )
                ),
            endDate:
                startDate.addingTimeInterval(
                    TimeInterval(
                        endMinute * 60
                    )
                ),
            score: score,
            level: level
        )
    }
}

// MARK: - Heart Rate Mock

private extension HistoryMock {

    static func makeHeartRateSamples(
        startDate: Date
    ) -> [HeartRateSample] {
        let ranges: [
            (
                minute: Int,
                minimum: Double,
                maximum: Double
            )
        ] = [
            (0, 58, 108),
            (10, 44, 128),
            (20, 44, 108),
            (30, 58, 118),
            (40, 75, 142),
            (50, 66, 158),
            (60, 84, 168),
            (70, 66, 162),
            (80, 58, 154),
            (90, 58, 162),
            (100, 66, 170),
            (110, 66, 182),
            (120, 58, 196),
            (130, 44, 188),
            (140, 58, 182),
            (150, 88, 170)
        ]

        return ranges.map { range in
            let intervalStart =
                startDate.addingTimeInterval(
                    TimeInterval(
                        range.minute * 60
                    )
                )

            let intervalEnd =
                intervalStart.addingTimeInterval(
                    10 * 60
                )

            return HeartRateSample(
                startDate: intervalStart,
                endDate: intervalEnd,
                minimumBPM: range.minimum,
                maximumBPM: range.maximum
            )
        }
    }
}

// MARK: - Body Gait Mock

private extension HistoryMock {

    static func makeBodyGaitSamples(
        startDate: Date
    ) -> [BodyGaitSample] {
        let values: [
            (
                minute: Int,
                score: Double
            )
        ] = [
            (0, 92),
            (8, 91),
            (16, 92),
            (24, 90),
            (32, 89),
            (40, 87),
            (48, 86),
            (56, 84),
            (64, 82),
            (72, 80),
            (80, 78),
            (88, 75),
            (96, 72),
            (104, 68),
            (112, 64),
            (120, 60),
            (128, 57),
            (136, 54),
            (144, 52),
            (152, 49),
            (160, 47)
        ]

        return values.map { value in
            BodyGaitSample(
                timestamp:
                    startDate
                    .addingTimeInterval(
                        TimeInterval(
                            value.minute * 60
                        )
                    ),
                score: value.score
            )
        }
    }
}

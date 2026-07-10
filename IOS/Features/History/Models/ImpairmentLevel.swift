//
//  ImpairmentLevel.swift
//  tonight
//

import SwiftUI

enum ImpairmentLevel: String, Codable, CaseIterable, Hashable {

    case sober
    case ok
    case tipsy
    case drunk

    var title: String {
        switch self {
        case .sober:
            return "Sober"

        case .ok:
            return "OK"

        case .tipsy:
            return "Tipsy"

        case .drunk:
            return "Drunk"
        }
    }

    var color: Color {
        switch self {
        case .sober:
            return Color(
                red: 48 / 255,
                green: 209 / 255,
                blue: 88 / 255
            )

        case .ok:
            return Color(
                red: 10 / 255,
                green: 190 / 255,
                blue: 225 / 255
            )

        case .tipsy:
            return Color(
                red: 1,
                green: 139 / 255,
                blue: 44 / 255
            )

        case .drunk:
            return Color(
                red: 1,
                green: 59 / 255,
                blue: 65 / 255
            )
        }
    }
}

// MARK: - Header Appearance

extension ImpairmentLevel {

    var statusTitle: String {
        switch self {
        case .sober:
            return "No Impairment"

        case .ok:
            return "Low Impairment"

        case .tipsy:
            return "Moderate Impairment"

        case .drunk:
            return "High Impairment"
        }
    }

    var statusColor: Color {
        switch self {
        case .sober:
            return Color(
                red: 48 / 255,
                green: 209 / 255,
                blue: 88 / 255
            )

        case .ok:
            return Color(
                red: 10 / 255,
                green: 190 / 255,
                blue: 225 / 255
            )

        case .tipsy:
            return Color(
                red: 1,
                green: 139 / 255,
                blue: 44 / 255
            )

        case .drunk:
            return Color(
                red: 1,
                green: 59 / 255,
                blue: 65 / 255
            )
        }
    }

    var glowColor: Color {
        switch self {
        case .sober:
            return Color.green

        case .ok:
            return Color.cyan

        case .tipsy:
            return Color.orange

        case .drunk:
            return Color.red
        }
    }
}

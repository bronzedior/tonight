//
//  HistoryViewModel.swift
//  tonight
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published private(set) var sessions:
        [SessionHistory]

    @Published var selectedSession:
        SessionHistory?

    @Published var isShowingDatePopover = false

    @Published var isShowingScoreSheet = false

    init(
        sessions: [SessionHistory] =
            SessionSyncManager.shared.sessions
    ) {
        let sortedSessions = sessions.sorted {
            $0.startDate > $1.startDate
        }

        self.sessions = sortedSessions
        self.selectedSession =
            sortedSessions.first
    }

    func updateSessions(
        _ newSessions: [SessionHistory]
    ) {
        let sortedSessions = newSessions.sorted {
            $0.startDate > $1.startDate
        }

        self.sessions = sortedSessions

        if let selectedID = selectedSession?.id,
           let stillThere = sortedSessions.first(where: { $0.id == selectedID }) {
            self.selectedSession = stillThere
        } else {
            self.selectedSession = sortedSessions.first
        }
    }

    var selectedDateText: String {
        guard let selectedSession else {
            return "Select Date"
        }

        return selectedSession.startDate.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
                .year()
        )
    }

    func toggleDatePopover() {
        isShowingDatePopover.toggle()
    }

    func selectSession(
        _ session: SessionHistory
    ) {
        selectedSession = session
        isShowingDatePopover = false
    }
}

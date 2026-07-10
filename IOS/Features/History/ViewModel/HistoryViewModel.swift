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
            HistoryMock.sessions
    ) {
        let sortedSessions = sessions.sorted {
            $0.startDate > $1.startDate
        }

        self.sessions = sortedSessions
        self.selectedSession =
            sortedSessions.first
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

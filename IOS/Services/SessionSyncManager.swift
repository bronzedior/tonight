//
//  SessionSyncManager.swift
//  tonight
//
//  Menerima ringkasan sesi dari Apple Watch (WatchConnectivity), memetakannya ke
//  `SessionHistory`, menyimpannya ke disk, dan mempublish daftar sesi untuk
//  History page. Selama belum ada sesi asli, jatuh ke data mock supaya halaman
//  tidak kosong.
//

import Foundation
import Combine
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

final class SessionSyncManager: NSObject, ObservableObject {

    static let shared = SessionSyncManager()

    /// Yang ditampilkan History page: sesi asli kalau ada, kalau tidak mock.
    @Published private(set) var sessions: [SessionHistory] = []

    /// Sesi asli yang diterima dari Watch (persisted).
    private var realSessions: [SessionHistory] = []

    private let storeURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("received_sessions.json")
    }()

    private override init() {
        super.init()
        loadFromDisk()
        refreshPublished()
        activateWCSession()
    }

    // MARK: - Activation

    private func activateWCSession() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
        #endif
    }

    // MARK: - Ingest

    /// Terima satu payload, map ke SessionHistory, simpan, publish. Idempotent by id.
    func ingest(_ transfer: SessionTransfer) {
        guard !realSessions.contains(where: { $0.id == transfer.id }) else { return }
        realSessions.insert(SessionSyncManager.map(transfer), at: 0)
        saveToDisk()
        refreshPublished()
    }

    private func refreshPublished() {
        let source = realSessions.isEmpty ? HistoryMock.sessions : realSessions
        sessions = source.sorted { $0.startDate > $1.startDate }
    }

    // MARK: - Persistence

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: storeURL) else { return }
        realSessions = (try? JSONDecoder().decode([SessionHistory].self, from: data)) ?? []
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(realSessions)
            try data.write(to: storeURL, options: .atomic)
        } catch {
            print("[SessionSyncManager] save error: \(error)")
        }
    }

    // MARK: - Mapping (SessionTransfer → SessionHistory)

    private static func map(_ t: SessionTransfer) -> SessionHistory {
        SessionHistory(
            id: t.id,
            startDate: t.startDate,
            endDate: t.endDate,
            peakLevel: ImpairmentLevel(rawValue: t.peakLevel) ?? .sober,
            peakScore: t.peakImpairmentScore,
            averageHeartRate: t.averageHeartRate,
            averageStability: t.averageStability,
            timeline: t.timeline.map {
                TimelinePoint(
                    startDate: $0.start,
                    endDate: $0.end,
                    score: $0.impairmentScore,
                    level: ImpairmentLevel(rawValue: $0.level) ?? .sober
                )
            },
            heartRateSamples: t.heartRateSamples.map {
                HeartRateSample(
                    startDate: $0.start,
                    endDate: $0.end,
                    minimumBPM: $0.minBPM,
                    maximumBPM: $0.maxBPM
                )
            },
            bodyGaitSamples: t.bodyGaitSamples.map {
                BodyGaitSample(timestamp: $0.timestamp, score: $0.score)
            }
        )
    }
}

// MARK: - WCSessionDelegate

#if canImport(WatchConnectivity)
extension SessionSyncManager: WCSessionDelegate {

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate agar tetap bisa menerima setelah ganti Watch.
        session.activate()
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        guard
            let data = userInfo["payload"] as? Data,
            let transfer = try? JSONDecoder().decode(SessionTransfer.self, from: data)
        else { return }

        Task { @MainActor in
            SessionSyncManager.shared.ingest(transfer)
        }
    }
}
#endif

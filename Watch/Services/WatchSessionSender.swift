//
//  WatchSessionSender.swift
//  tonight watch Watch App

import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

final class WatchSessionSender: NSObject {

    static let shared = WatchSessionSender()

    private override init() {
        super.init()
        activate()
    }

    private func activate() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        #endif
    }

    /// Encode payload ke JSON dan antrikan pengirimannya ke iPhone.
    func send(_ transfer: SessionTransfer) {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else {
            print("[WatchSessionSender] WCSession not supported")
            return
        }
        do {
            let data = try JSONEncoder().encode(transfer)
            WCSession.default.transferUserInfo(["payload": data])
        } catch {
            print("[WatchSessionSender] encode error: \(error)")
        }
        #endif
    }
}

#if canImport(WatchConnectivity)
extension WatchSessionSender: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}
}
#endif

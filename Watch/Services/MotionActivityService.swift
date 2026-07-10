import Foundation
import CoreMotion

final class MotionActivityService {

    // MARK: - Properties

    private let activityManager = CMMotionActivityManager()

    var isAvailable: Bool { CMMotionActivityManager.isActivityAvailable() }

    private(set) var currentMode: ScoringMode = .stationary

    /// Apakah updates sedang berjalan.
    private var isRunning = false

    // MARK: - Callbacks

    /// Dipanggil setiap mode berubah (mis. stationary → walking).
    var onModeChange: ((ScoringMode) -> Void)?

    // MARK: - Control

    func start() {
        guard !isRunning else { return }

        guard isAvailable else {
            notify(mode: .stationary, force: true)
            return
        }

        isRunning = true

        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self, let activity else { return }

           
            guard activity.confidence != .low else { return }

            let mode: ScoringMode = (activity.walking || activity.running)
                ? .walking
                : .stationary

            self.notify(mode: mode, force: false)
        }
    }

    func stop() {
        guard isRunning else { return }
        activityManager.stopActivityUpdates()
        isRunning = false
        currentMode = .stationary
    }

    // MARK: - Private

    private func notify(mode: ScoringMode, force: Bool) {
        guard force || mode != currentMode else { return }
        currentMode = mode
        onModeChange?(mode)
    }
}

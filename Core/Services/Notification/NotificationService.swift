import Foundation
import UserNotifications

/// Posts silent local notifications when the current track changes.
@MainActor
final class NotificationService {
    private let playerService: PlayerService
    private let logger = DiagnosticsLogger.notification
    private var observationTask: Task<Void, Never>?
    private var lastNotifiedTrackId: String?

    init(playerService: PlayerService) {
        self.playerService = playerService
        requestAuthorization()
        startObserving()
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Authorization

    private func requestAuthorization() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert])
                logger.info("Notification authorization: \(granted)")
            } catch {
                logger.error("Notification authorization failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Observation

    private func startObserving() {
        observationTask = Task { [weak self] in
            guard let self else { return }
            var previousTrack: Song?

            while !Task.isCancelled {
                let currentTrack = playerService.currentTrack

                // Only notify on actual track changes with valid title
                if let track = currentTrack,
                   track.id != previousTrack?.id,
                   track.id != self.lastNotifiedTrackId,
                   track.title != "Loading..."
                {
                    await postTrackNotification(track)
                    lastNotifiedTrackId = track.id
                }

                previousTrack = currentTrack
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    // MARK: - Notification

    private func postTrackNotification(_ track: Song) async {
        let content = UNMutableNotificationContent()
        content.title = track.title
        content.body = track.artistsDisplay.isEmpty ? "Unknown Artist" : track.artistsDisplay
        content.sound = nil // Silent notification

        let request = UNNotificationRequest(
            identifier: "track-change-\(track.id)",
            content: content,
            trigger: nil // Deliver immediately
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            logger.debug("Posted notification for: \(track.title)")
        } catch {
            logger.error("Failed to post notification: \(error.localizedDescription)")
        }
    }

    func stopObserving() {
        observationTask?.cancel()
        observationTask = nil
    }
}

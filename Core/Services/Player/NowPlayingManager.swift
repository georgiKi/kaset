import AppKit
import Foundation
import MediaPlayer
import Observation
import os

/// Manages Now Playing info and remote command center integration.
@MainActor
@Observable
final class NowPlayingManager {
    private let playerService: PlayerService
    private let logger = DiagnosticsLogger.player
    private var observationTask: Task<Void, Never>?
    private var artworkCache: [URL: CGImage] = [:]

    init(playerService: PlayerService) {
        self.playerService = playerService
        setupRemoteCommands()
        startObserving()
    }

    func stopObserving() {
        observationTask?.cancel()
        observationTask = nil
    }

    // MARK: - Remote Commands

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Capture playerService directly to avoid capturing self
        let player = playerService

        // Play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            Task { @MainActor in
                await player.resume()
            }
            return .success
        }

        // Pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ in
            Task { @MainActor in
                await player.pause()
            }
            return .success
        }

        // Toggle play/pause command
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { _ in
            Task { @MainActor in
                await player.playPause()
            }
            return .success
        }

        // Next track command
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { _ in
            Task { @MainActor in
                await player.next()
            }
            return .success
        }

        // Previous track command
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { _ in
            Task { @MainActor in
                await player.previous()
            }
            return .success
        }

        // Change playback position command
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let position = positionEvent.positionTime
            Task { @MainActor in
                await player.seek(to: position)
            }
            return .success
        }

        logger.info("Remote commands configured")
    }

    // MARK: - Now Playing Info

    private func startObserving() {
        observationTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                self?.updateNowPlayingInfo()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func updateNowPlayingInfo() {
        guard let track = playerService.currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artistsDisplay,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: playerService.progress,
            MPMediaItemPropertyPlaybackDuration: playerService.duration,
            MPNowPlayingInfoPropertyPlaybackRate: playerService.isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
        ]

        if let album = track.album {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album.title
        }

        // Note: Artwork disabled due to thread-safety issues with MPMediaItemArtwork closure
        // The closure is called on a background thread and NSImage is not thread-safe

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func fetchArtwork(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let nsImage = NSImage(data: data),
                  let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            else { return }

            await MainActor.run {
                artworkCache[url] = cgImage
                updateNowPlayingInfo()
            }
        } catch {
            await MainActor.run {
                logger.debug("Failed to fetch artwork: \(error.localizedDescription)")
            }
        }
    }
}

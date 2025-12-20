import XCTest
@testable import YouTubeMusic

/// Tests for PlayerService.
@MainActor
final class PlayerServiceTests: XCTestCase {
    var playerService: PlayerService!

    override func setUp() async throws {
        playerService = PlayerService()
    }

    override func tearDown() async throws {
        playerService = nil
    }

    func testInitialState() {
        XCTAssertEqual(playerService.state, .idle)
        XCTAssertNil(playerService.currentTrack)
        XCTAssertFalse(playerService.isPlaying)
        XCTAssertEqual(playerService.progress, 0)
        XCTAssertEqual(playerService.duration, 0)
        XCTAssertEqual(playerService.volume, 1.0)
    }

    func testIsPlayingProperty() {
        XCTAssertFalse(playerService.isPlaying)
        // Note: We can't easily test state changes without mocking the WebView
    }

    func testPlaybackStateEquatable() {
        let state1 = PlayerService.PlaybackState.playing
        let state2 = PlayerService.PlaybackState.playing
        XCTAssertEqual(state1, state2)

        let state3 = PlayerService.PlaybackState.paused
        XCTAssertNotEqual(state1, state3)

        let error1 = PlayerService.PlaybackState.error("Test error")
        let error2 = PlayerService.PlaybackState.error("Test error")
        XCTAssertEqual(error1, error2)

        let error3 = PlayerService.PlaybackState.error("Different error")
        XCTAssertNotEqual(error1, error3)
    }

    func testPlaybackStateIsPlaying() {
        XCTAssertTrue(PlayerService.PlaybackState.playing.isPlaying)
        XCTAssertFalse(PlayerService.PlaybackState.paused.isPlaying)
        XCTAssertFalse(PlayerService.PlaybackState.idle.isPlaying)
        XCTAssertFalse(PlayerService.PlaybackState.loading.isPlaying)
        XCTAssertFalse(PlayerService.PlaybackState.buffering.isPlaying)
        XCTAssertFalse(PlayerService.PlaybackState.ended.isPlaying)
        XCTAssertFalse(PlayerService.PlaybackState.error("test").isPlaying)
    }

    func testQueueInitiallyEmpty() {
        XCTAssertTrue(playerService.queue.isEmpty)
        XCTAssertEqual(playerService.currentIndex, 0)
    }

    func testUpdatePlaybackState() {
        playerService.updatePlaybackState(isPlaying: true, progress: 30.0, duration: 180.0)

        XCTAssertEqual(playerService.state, .playing)
        XCTAssertEqual(playerService.progress, 30.0)
        XCTAssertEqual(playerService.duration, 180.0)
        XCTAssertTrue(playerService.isPlaying)
    }

    func testUpdatePlaybackStatePaused() {
        // First set to playing
        playerService.updatePlaybackState(isPlaying: true, progress: 30.0, duration: 180.0)
        XCTAssertEqual(playerService.state, .playing)

        // Then pause
        playerService.updatePlaybackState(isPlaying: false, progress: 30.0, duration: 180.0)
        XCTAssertEqual(playerService.state, .paused)
        XCTAssertFalse(playerService.isPlaying)
    }

    func testUpdateTrackMetadata() {
        playerService.updateTrackMetadata(
            title: "Test Song",
            artist: "Test Artist",
            thumbnailUrl: "https://example.com/thumb.jpg"
        )

        XCTAssertNotNil(playerService.currentTrack)
        XCTAssertEqual(playerService.currentTrack?.title, "Test Song")
        XCTAssertEqual(playerService.currentTrack?.artistsDisplay, "Test Artist")
        XCTAssertEqual(playerService.currentTrack?.thumbnailURL?.absoluteString, "https://example.com/thumb.jpg")
    }

    func testUpdateTrackMetadataWithEmptyThumbnail() {
        playerService.updateTrackMetadata(
            title: "Test Song",
            artist: "Test Artist",
            thumbnailUrl: ""
        )

        XCTAssertNotNil(playerService.currentTrack)
        XCTAssertEqual(playerService.currentTrack?.title, "Test Song")
        XCTAssertNil(playerService.currentTrack?.thumbnailURL)
    }

    func testConfirmPlaybackStarted() {
        playerService.showMiniPlayer = true
        playerService.confirmPlaybackStarted()

        XCTAssertFalse(playerService.showMiniPlayer)
        XCTAssertEqual(playerService.state, .playing)
    }

    func testMiniPlayerDismissed() {
        playerService.showMiniPlayer = true
        playerService.miniPlayerDismissed()

        XCTAssertFalse(playerService.showMiniPlayer)
    }
}

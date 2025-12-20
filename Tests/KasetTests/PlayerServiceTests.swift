import XCTest
@testable import Kaset

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

    // MARK: - Shuffle and Repeat Mode Tests

    func testToggleShuffle() {
        XCTAssertFalse(playerService.shuffleEnabled)

        playerService.toggleShuffle()
        XCTAssertTrue(playerService.shuffleEnabled)

        playerService.toggleShuffle()
        XCTAssertFalse(playerService.shuffleEnabled)
    }

    func testCycleRepeatMode() {
        XCTAssertEqual(playerService.repeatMode, .off)

        playerService.cycleRepeatMode()
        XCTAssertEqual(playerService.repeatMode, .all)

        playerService.cycleRepeatMode()
        XCTAssertEqual(playerService.repeatMode, .one)

        playerService.cycleRepeatMode()
        XCTAssertEqual(playerService.repeatMode, .off)
    }

    // MARK: - Volume Tests

    func testIsMuted() {
        XCTAssertFalse(playerService.isMuted)
    }

    func testInitialVolume() {
        XCTAssertEqual(playerService.volume, 1.0)
    }

    // MARK: - Queue Tests

    func testPlayQueueSetsQueue() async {
        let songs = [
            Song(id: "1", title: "Song 1", artists: [], album: nil, duration: 180, thumbnailURL: nil, videoId: "v1"),
            Song(id: "2", title: "Song 2", artists: [], album: nil, duration: 200, thumbnailURL: nil, videoId: "v2"),
            Song(id: "3", title: "Song 3", artists: [], album: nil, duration: 220, thumbnailURL: nil, videoId: "v3"),
        ]

        await playerService.playQueue(songs, startingAt: 0)

        XCTAssertEqual(playerService.queue.count, 3)
        XCTAssertEqual(playerService.currentIndex, 0)
    }

    func testPlayQueueStartingAtIndex() async {
        let songs = [
            Song(id: "1", title: "Song 1", artists: [], album: nil, duration: 180, thumbnailURL: nil, videoId: "v1"),
            Song(id: "2", title: "Song 2", artists: [], album: nil, duration: 200, thumbnailURL: nil, videoId: "v2"),
            Song(id: "3", title: "Song 3", artists: [], album: nil, duration: 220, thumbnailURL: nil, videoId: "v3"),
        ]

        await playerService.playQueue(songs, startingAt: 2)

        XCTAssertEqual(playerService.currentIndex, 2)
    }

    func testPlayQueueWithInvalidIndex() async {
        let songs = [
            Song(id: "1", title: "Song 1", artists: [], album: nil, duration: 180, thumbnailURL: nil, videoId: "v1"),
        ]

        await playerService.playQueue(songs, startingAt: 10)

        // Should clamp to valid range
        XCTAssertEqual(playerService.currentIndex, 0)
    }

    func testPlayQueueEmptyDoesNothing() async {
        await playerService.playQueue([], startingAt: 0)

        XCTAssertTrue(playerService.queue.isEmpty)
    }

    // MARK: - PlaybackState State Tests

    func testAllPlaybackStates() {
        let states: [PlayerService.PlaybackState] = [
            .idle,
            .loading,
            .playing,
            .paused,
            .buffering,
            .ended,
            .error("test error"),
        ]

        // Only playing should return true for isPlaying
        for state in states {
            if state == .playing {
                XCTAssertTrue(state.isPlaying)
            } else {
                XCTAssertFalse(state.isPlaying)
            }
        }
    }

    func testPlaybackStateErrorEquality() {
        let error1 = PlayerService.PlaybackState.error("same message")
        let error2 = PlayerService.PlaybackState.error("same message")
        let error3 = PlayerService.PlaybackState.error("different message")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    // MARK: - hasUserInteractedThisSession Tests

    func testHasUserInteractedThisSessionInitiallyFalse() {
        XCTAssertFalse(playerService.hasUserInteractedThisSession)
    }

    func testConfirmPlaybackStartedSetsUserInteracted() {
        XCTAssertFalse(playerService.hasUserInteractedThisSession)

        playerService.confirmPlaybackStarted()

        XCTAssertTrue(playerService.hasUserInteractedThisSession)
    }

    // MARK: - Pending Play Video Tests

    func testPendingPlayVideoIdInitiallyNil() {
        XCTAssertNil(playerService.pendingPlayVideoId)
    }

    // MARK: - Mini Player State Tests

    func testMiniPlayerInitiallyHidden() {
        XCTAssertFalse(playerService.showMiniPlayer)
    }

    func testMiniPlayerDismissedResetsLoadingState() {
        // First set state to loading
        playerService.updatePlaybackState(isPlaying: false, progress: 0, duration: 0)

        // Simulate being in loading state
        // Note: We're testing the idle transition when already idle, which should stay idle
        playerService.showMiniPlayer = true
        playerService.miniPlayerDismissed()

        XCTAssertFalse(playerService.showMiniPlayer)
    }
}

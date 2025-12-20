import XCTest
@testable import Kaset

/// Extended tests for YTMusicError.
final class YTMusicErrorTests: XCTestCase {
    // MARK: - Error Description Tests

    func testAuthExpiredDescription() {
        let error = YTMusicError.authExpired
        XCTAssertEqual(error.errorDescription, "Your session has expired. Please sign in again.")
    }

    func testNotAuthenticatedDescription() {
        let error = YTMusicError.notAuthenticated
        XCTAssertEqual(error.errorDescription, "You're not signed in. Please sign in to continue.")
    }

    func testNetworkErrorDescription() {
        let underlying = URLError(.notConnectedToInternet)
        let error = YTMusicError.networkError(underlying: underlying)
        XCTAssertTrue(error.errorDescription?.contains("Network error") ?? false)
    }

    func testParseErrorDescription() {
        let error = YTMusicError.parseError(message: "Invalid JSON")
        XCTAssertEqual(error.errorDescription, "Failed to parse response: Invalid JSON")
    }

    func testApiErrorWithCodeDescription() {
        let error = YTMusicError.apiError(message: "Rate limited", code: 429)
        XCTAssertEqual(error.errorDescription, "API error (429): Rate limited")
    }

    func testApiErrorWithoutCodeDescription() {
        let error = YTMusicError.apiError(message: "Something went wrong", code: nil)
        XCTAssertEqual(error.errorDescription, "API error: Something went wrong")
    }

    func testPlaybackErrorDescription() {
        let error = YTMusicError.playbackError(message: "Content not available")
        XCTAssertEqual(error.errorDescription, "Playback error: Content not available")
    }

    func testUnknownErrorDescription() {
        let error = YTMusicError.unknown(message: "An unexpected error occurred")
        XCTAssertEqual(error.errorDescription, "An unexpected error occurred")
    }

    // MARK: - Recovery Suggestion Tests

    func testAuthExpiredRecoverySuggestion() {
        let error = YTMusicError.authExpired
        XCTAssertEqual(error.recoverySuggestion, "Sign in to your YouTube Music account.")
    }

    func testNotAuthenticatedRecoverySuggestion() {
        let error = YTMusicError.notAuthenticated
        XCTAssertEqual(error.recoverySuggestion, "Sign in to your YouTube Music account.")
    }

    func testNetworkErrorRecoverySuggestion() {
        let error = YTMusicError.networkError(underlying: URLError(.timedOut))
        XCTAssertEqual(error.recoverySuggestion, "Check your internet connection and try again.")
    }

    func testParseErrorRecoverySuggestion() {
        let error = YTMusicError.parseError(message: "Bad data")
        XCTAssertEqual(error.recoverySuggestion, "Try again. If the problem persists, the service may be temporarily unavailable.")
    }

    func testApiErrorRecoverySuggestion() {
        let error = YTMusicError.apiError(message: "Error", code: 500)
        XCTAssertEqual(error.recoverySuggestion, "Try again. If the problem persists, the service may be temporarily unavailable.")
    }

    func testPlaybackErrorRecoverySuggestion() {
        let error = YTMusicError.playbackError(message: "Error")
        XCTAssertEqual(error.recoverySuggestion, "Try playing a different track.")
    }

    func testUnknownErrorRecoverySuggestion() {
        let error = YTMusicError.unknown(message: "Error")
        XCTAssertEqual(error.recoverySuggestion, "Try again later.")
    }

    // MARK: - Requires Reauth Tests

    func testAuthExpiredRequiresReauth() {
        XCTAssertTrue(YTMusicError.authExpired.requiresReauth)
    }

    func testNotAuthenticatedRequiresReauth() {
        XCTAssertTrue(YTMusicError.notAuthenticated.requiresReauth)
    }

    func testNetworkErrorDoesNotRequireReauth() {
        let error = YTMusicError.networkError(underlying: URLError(.timedOut))
        XCTAssertFalse(error.requiresReauth)
    }

    func testParseErrorDoesNotRequireReauth() {
        XCTAssertFalse(YTMusicError.parseError(message: "Error").requiresReauth)
    }

    func testApiErrorDoesNotRequireReauth() {
        XCTAssertFalse(YTMusicError.apiError(message: "Error", code: 500).requiresReauth)
    }

    func testPlaybackErrorDoesNotRequireReauth() {
        XCTAssertFalse(YTMusicError.playbackError(message: "Error").requiresReauth)
    }

    func testUnknownErrorDoesNotRequireReauth() {
        XCTAssertFalse(YTMusicError.unknown(message: "Error").requiresReauth)
    }

    // MARK: - Debug Description Tests

    func testNetworkErrorDebugDescription() {
        let underlying = URLError(.notConnectedToInternet)
        let error = YTMusicError.networkError(underlying: underlying)
        let debugDesc = error.debugDescription
        XCTAssertTrue(debugDesc.contains("YTMusicError.networkError"))
    }

    func testNonNetworkErrorDebugDescription() {
        let error = YTMusicError.authExpired
        XCTAssertEqual(error.debugDescription, error.errorDescription)
    }

    func testParseErrorDebugDescription() {
        let error = YTMusicError.parseError(message: "Bad JSON")
        XCTAssertEqual(error.debugDescription, "Failed to parse response: Bad JSON")
    }
}

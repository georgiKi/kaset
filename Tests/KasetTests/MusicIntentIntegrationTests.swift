import Foundation
import FoundationModels
import Testing
@testable import Kaset

// MARK: - MusicIntent Integration Tests

/// Integration tests that call the actual Apple Intelligence LLM.
///
/// These tests validate that natural language prompts are correctly parsed
/// into `MusicIntent` structs. They require macOS 26+ with Apple Intelligence.
///
/// ## Running These Tests
///
/// Run only integration tests:
/// ```bash
/// xcodebuild test -scheme Kaset -destination 'platform=macOS' \
///   -only-testing:KasetTests/MusicIntentIntegrationTests
/// ```
///
/// Run all unit tests EXCEPT integration tests:
/// ```bash
/// xcodebuild test -scheme Kaset -destination 'platform=macOS' \
///   -only-testing:KasetTests -skip-testing:KasetTests/MusicIntentIntegrationTests
/// ```
///
/// Skip by tag:
/// ```bash
/// xcodebuild test -scheme Kaset -destination 'platform=macOS' \
///   -only-testing:KasetTests -skip-test-tag integration
/// ```
@Suite("MusicIntent Integration", .tags(.integration, .slow), .serialized)
@MainActor
struct MusicIntentIntegrationTests {
    // MARK: - Shared Session

    /// System prompt for intent parsing - kept minimal to fit in context window.
    private static let systemPrompt = """
        Parse music commands into MusicIntent. Actions: play, queue, shuffle, like, dislike, \
        skip, previous, pause, resume, search. Fields: query, artist, genre, mood, era, version, activity.
        """

    // MARK: - Test Helper

    /// Parses a natural language prompt into a MusicIntent using the LLM.
    /// Creates a fresh session per call to avoid context window overflow.
    private func parseIntent(from prompt: String) async throws -> MusicIntent {
        guard SystemLanguageModel.default.availability == .available else {
            throw AIUnavailableError()
        }
        // Create a fresh session each time to avoid context accumulation
        let session = LanguageModelSession(instructions: Self.systemPrompt)
        let response = try await session.respond(to: prompt, generating: MusicIntent.self)
        return response.content
    }

    // MARK: - Basic Actions (Parameterized)

    @Test("Parses playback control commands", arguments: [
        (prompt: "Play music", expectedAction: MusicAction.play),
        (prompt: "Skip this song", expectedAction: MusicAction.skip),
        (prompt: "Next track", expectedAction: MusicAction.skip),
        (prompt: "Pause", expectedAction: MusicAction.pause),
        (prompt: "Resume playback", expectedAction: MusicAction.resume),
        (prompt: "Like this song", expectedAction: MusicAction.like),
        (prompt: "Add jazz to queue", expectedAction: MusicAction.queue),
    ])
    func parsePlaybackCommand(prompt: String, expectedAction: MusicAction) async throws {
        let intent = try await parseIntent(from: prompt)
        #expect(intent.action == expectedAction)
    }

    // MARK: - Content Queries (Parameterized)

    @Test("Parses mood-based queries", arguments: [
        (prompt: "Play something chill", expected: "chill"),
        (prompt: "Play upbeat music", expected: "upbeat"),
    ])
    func parseMoodQuery(prompt: String, expected: String) async throws {
        let intent = try await parseIntent(from: prompt)
        #expect(intent.action == .play)
        let combined = "\(intent.mood) \(intent.query)".lowercased()
        #expect(combined.contains(expected), "Expected '\(expected)' in mood or query")
    }

    @Test("Parses genre queries", arguments: [
        (prompt: "Play jazz", expected: "jazz"),
        (prompt: "Play some rock", expected: "rock"),
    ])
    func parseGenreQuery(prompt: String, expected: String) async throws {
        let intent = try await parseIntent(from: prompt)
        #expect(intent.action == .play)
        let combined = "\(intent.genre) \(intent.query)".lowercased()
        #expect(combined.contains(expected), "Expected '\(expected)' in genre or query")
    }

    @Test("Parses era/decade queries", arguments: [
        (prompt: "Play 80s hits", expected: "80"),
        (prompt: "Play 90s music", expected: "90"),
    ])
    func parseEraQuery(prompt: String, expected: String) async throws {
        let intent = try await parseIntent(from: prompt)
        #expect(intent.action == .play)
        let combined = "\(intent.era) \(intent.query)".lowercased()
        #expect(combined.contains(expected), "Expected '\(expected)' in era or query")
    }

    @Test("Parses artist queries", arguments: [
        (prompt: "Play Beatles", expected: "beatles"),
        (prompt: "Play Taylor Swift songs", expected: "taylor"),
    ])
    func parseArtistQuery(prompt: String, expected: String) async throws {
        let intent = try await parseIntent(from: prompt)
        #expect(intent.action == .play)
        let combined = "\(intent.artist) \(intent.query)".lowercased()
        #expect(combined.contains(expected), "Expected '\(expected)' in artist or query")
    }

    @Test("Parses activity-based queries", arguments: [
        (prompt: "Play music for studying", expected: "study"),
        (prompt: "Play workout songs", expected: "workout"),
    ])
    func parseActivityQuery(prompt: String, expected: String) async throws {
        let intent = try await parseIntent(from: prompt)
        #expect(intent.action == .play)
        let combined = "\(intent.activity) \(intent.query)".lowercased()
        #expect(combined.contains(expected), "Expected '\(expected)' in activity or query")
    }

    // MARK: - Complex Query

    @Test("Parses complex multi-component query")
    func parseComplexQuery() async throws {
        let intent = try await parseIntent(from: "Play chill jazz from the 80s")
        #expect(intent.action == .play)
        let components = [intent.mood, intent.genre, intent.era].filter { !$0.isEmpty }
        #expect(components.count >= 2, "Expected at least 2 components populated")
    }

    @Test("Parses version type query")
    func parseVersionQuery() async throws {
        let intent = try await parseIntent(from: "Play acoustic covers")
        #expect(intent.action == .play)
        let combined = "\(intent.version) \(intent.query)".lowercased()
        #expect(combined.contains("acoustic"), "Expected 'acoustic' in version or query")
    }
}

// MARK: - AIUnavailableError

/// Error thrown when Apple Intelligence is not available.
/// Tests catching this error should be considered skipped.
struct AIUnavailableError: Error, CustomStringConvertible {
    var description: String { "Apple Intelligence not available on this device" }
}

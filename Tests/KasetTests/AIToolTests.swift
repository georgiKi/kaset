import Foundation
import Testing
@testable import Kaset

// MARK: - MusicSearchToolTests

/// Tests for MusicSearchTool output formatting and behavior.
@available(macOS 26.0, *)
@Suite("MusicSearchTool", .tags(.api), .serialized)
@MainActor
struct MusicSearchToolTests {
    let mockClient: MockYTMusicClient
    let tool: MusicSearchTool

    init() {
        self.mockClient = MockYTMusicClient()
        self.tool = MusicSearchTool(client: self.mockClient)
    }

    @Test("Tool has correct name and description")
    func toolMetadata() {
        #expect(self.tool.name == "searchMusic")
        #expect(self.tool.description.contains("YouTube Music"))
    }

    @Test("Search returns formatted song results")
    func searchReturnsSongs() async throws {
        self.mockClient.searchResponse = TestFixtures.makeSearchResponse(
            songCount: 3, albumCount: 0, artistCount: 0, playlistCount: 0
        )

        let args = MusicSearchTool.Arguments(query: "jazz", filter: "songs")
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("Search results for 'jazz'"))
        #expect(result.contains("SONG:"))
        #expect(result.contains("videoId:"))
        #expect(self.mockClient.searchCalled)
    }

    @Test("Search returns formatted album results")
    func searchReturnsAlbums() async throws {
        self.mockClient.searchResponse = TestFixtures.makeSearchResponse(
            songCount: 0, albumCount: 2, artistCount: 0, playlistCount: 0
        )

        let args = MusicSearchTool.Arguments(query: "rock albums", filter: "albums")
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("ALBUM:"))
        #expect(result.contains("browseId:"))
    }

    @Test("Search returns formatted artist results")
    func searchReturnsArtists() async throws {
        self.mockClient.searchResponse = TestFixtures.makeSearchResponse(
            songCount: 0, albumCount: 0, artistCount: 2, playlistCount: 0
        )

        let args = MusicSearchTool.Arguments(query: "Beatles", filter: "artists")
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("ARTIST:"))
        #expect(result.contains("channelId:"))
    }

    @Test("Search returns formatted playlist results")
    func searchReturnsPlaylists() async throws {
        self.mockClient.searchResponse = TestFixtures.makeSearchResponse(
            songCount: 0, albumCount: 0, artistCount: 0, playlistCount: 2
        )

        let args = MusicSearchTool.Arguments(query: "workout", filter: "playlists")
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("PLAYLIST:"))
        #expect(result.contains("playlistId:"))
    }

    @Test("Search with 'all' filter returns mixed results")
    func searchAllFilterReturnsMixed() async throws {
        self.mockClient.searchResponse = TestFixtures.makeSearchResponse(
            songCount: 2, albumCount: 1, artistCount: 1, playlistCount: 1
        )

        let args = MusicSearchTool.Arguments(query: "pop", filter: "all")
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("SONG:"))
        #expect(result.contains("ALBUM:"))
        #expect(result.contains("ARTIST:"))
        #expect(result.contains("PLAYLIST:"))
    }

    @Test("Search with empty filter returns all results")
    func searchEmptyFilterReturnsAll() async throws {
        self.mockClient.searchResponse = TestFixtures.makeSearchResponse(
            songCount: 2, albumCount: 1, artistCount: 1, playlistCount: 1
        )

        let args = MusicSearchTool.Arguments(query: "music", filter: "")
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("SONG:"))
        #expect(result.contains("ALBUM:"))
    }

    @Test("Search with no results returns appropriate message")
    func searchNoResults() async throws {
        self.mockClient.searchResponse = SearchResponse.empty

        let args = MusicSearchTool.Arguments(query: "xyznonexistent", filter: "all")
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("No results found"))
        #expect(result.contains("xyznonexistent"))
    }

    @Test("Search propagates errors")
    func searchPropagatesErrors() async throws {
        self.mockClient.shouldThrowError = YTMusicError.networkError(
            message: "Connection failed"
        )

        let args = MusicSearchTool.Arguments(query: "test", filter: "songs")

        do {
            _ = try await self.tool.call(arguments: args)
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is YTMusicError)
        }
    }
}

// MARK: - LibraryToolTests

/// Tests for LibraryTool output formatting and behavior.
@available(macOS 26.0, *)
@Suite("LibraryTool", .tags(.api), .serialized)
@MainActor
struct LibraryToolTests {
    let mockClient: MockYTMusicClient
    let tool: LibraryTool

    init() {
        self.mockClient = MockYTMusicClient()
        self.tool = LibraryTool(client: self.mockClient)
    }

    @Test("Tool has correct name and description")
    func toolMetadata() {
        #expect(self.tool.name == "getUserLibrary")
        #expect(self.tool.description.contains("library"))
    }

    @Test("Fetches liked songs with 'liked' contentType")
    func fetchLikedSongs() async throws {
        self.mockClient.likedSongs = TestFixtures.makeSongs(count: 5)

        let args = LibraryTool.Arguments(contentType: "liked", limit: 10)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("Liked Songs"))
        #expect(result.contains("5 total"))
        #expect(result.contains("videoId:"))
        #expect(self.mockClient.getLikedSongsCalled)
    }

    @Test("Fetches liked songs with 'favorites' contentType")
    func fetchFavorites() async throws {
        self.mockClient.likedSongs = TestFixtures.makeSongs(count: 3)

        let args = LibraryTool.Arguments(contentType: "favorites", limit: 10)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("Liked Songs"))
        #expect(self.mockClient.getLikedSongsCalled)
    }

    @Test("Fetches playlists with 'playlists' contentType")
    func fetchPlaylists() async throws {
        self.mockClient.libraryPlaylists = [
            TestFixtures.makePlaylist(id: "VL1", title: "My Playlist 1"),
            TestFixtures.makePlaylist(id: "VL2", title: "My Playlist 2"),
        ]

        let args = LibraryTool.Arguments(contentType: "playlists", limit: 10)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("Your Playlists"))
        #expect(result.contains("2 total"))
        #expect(result.contains("playlistId:"))
        #expect(self.mockClient.getLibraryPlaylistsCalled)
    }

    @Test("Fetches summary with 'all' contentType")
    func fetchSummary() async throws {
        self.mockClient.likedSongs = TestFixtures.makeSongs(count: 10)
        self.mockClient.libraryPlaylists = [
            TestFixtures.makePlaylist(id: "VL1", title: "Playlist 1"),
        ]

        let args = LibraryTool.Arguments(contentType: "all", limit: 5)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("Library Summary"))
        #expect(result.contains("10 liked songs"))
        #expect(result.contains("1 playlists"))
    }

    @Test("Limit clamps to maximum of 50")
    func limitClampsToMax() async throws {
        self.mockClient.likedSongs = TestFixtures.makeSongs(count: 100)

        let args = LibraryTool.Arguments(contentType: "liked", limit: 100)
        let result = try await self.tool.call(arguments: args)

        // Should show "showing 50" since we cap at 50
        #expect(result.contains("100 total"))
        #expect(result.contains("showing 50"))
    }

    @Test("Limit clamps to minimum of 1")
    func limitClampsToMin() async throws {
        self.mockClient.likedSongs = TestFixtures.makeSongs(count: 5)

        let args = LibraryTool.Arguments(contentType: "liked", limit: 0)
        let result = try await self.tool.call(arguments: args)

        // Should return at least 1 result
        #expect(result.contains("Liked Songs"))
    }

    @Test("Empty library returns appropriate message")
    func emptyLibrary() async throws {
        self.mockClient.likedSongs = []
        self.mockClient.libraryPlaylists = []

        let args = LibraryTool.Arguments(contentType: "all", limit: 10)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("0 liked songs"))
        #expect(result.contains("0 playlists"))
    }
}

// MARK: - PlaylistToolTests

/// Tests for PlaylistTool output formatting and behavior.
@available(macOS 26.0, *)
@Suite("PlaylistTool", .tags(.api), .serialized)
@MainActor
struct PlaylistToolTests {
    let mockClient: MockYTMusicClient
    let tool: PlaylistTool

    init() {
        self.mockClient = MockYTMusicClient()
        self.tool = PlaylistTool(client: self.mockClient)
    }

    @Test("Tool has correct name and description")
    func toolMetadata() {
        #expect(self.tool.name == "getPlaylistContents")
        #expect(self.tool.description.contains("playlist"))
    }

    @Test("Fetches playlist with tracks")
    func fetchPlaylistWithTracks() async throws {
        let playlistId = "VLtest123"
        self.mockClient.playlistDetails[playlistId] = TestFixtures.makePlaylistDetail(
            playlist: TestFixtures.makePlaylist(id: playlistId, title: "Test Playlist"),
            trackCount: 10
        )

        let args = PlaylistTool.Arguments(playlistId: playlistId, limit: 25)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("Test Playlist"))
        #expect(result.contains("Total tracks: 10"))
        #expect(result.contains("videoId:"))
        #expect(self.mockClient.getPlaylistCalled)
        #expect(self.mockClient.getPlaylistIds.contains(playlistId))
    }

    @Test("Limit parameter restricts track count")
    func limitRestrictsTracks() async throws {
        let playlistId = "VLlarge"
        self.mockClient.playlistDetails[playlistId] = TestFixtures.makePlaylistDetail(
            playlist: TestFixtures.makePlaylist(id: playlistId, title: "Large Playlist"),
            trackCount: 100
        )

        let args = PlaylistTool.Arguments(playlistId: playlistId, limit: 10)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("showing first 10"))
        #expect(result.contains("Total tracks: 100"))
    }

    @Test("Limit clamps to maximum of 50")
    func limitClampsTo50() async throws {
        let playlistId = "VLhuge"
        self.mockClient.playlistDetails[playlistId] = TestFixtures.makePlaylistDetail(
            playlist: TestFixtures.makePlaylist(id: playlistId, title: "Huge Playlist"),
            trackCount: 200
        )

        let args = PlaylistTool.Arguments(playlistId: playlistId, limit: 100)
        let result = try await self.tool.call(arguments: args)

        // Should cap at 50
        #expect(result.contains("showing first 50"))
    }

    @Test("Playlist with description shows it")
    func playlistWithDescription() async throws {
        let playlistId = "VLdesc"
        var playlist = TestFixtures.makePlaylist(id: playlistId, title: "Described Playlist")
        // PlaylistDetail includes description from playlist
        self.mockClient.playlistDetails[playlistId] = PlaylistDetail(
            playlist: playlist,
            tracks: TestFixtures.makeSongs(count: 5),
            duration: "15 minutes",
            description: "A wonderful playlist of jazz classics"
        )

        let args = PlaylistTool.Arguments(playlistId: playlistId, limit: 10)
        let result = try await self.tool.call(arguments: args)

        #expect(result.contains("Description:"))
        #expect(result.contains("jazz classics"))
    }

    @Test("Playlist not found throws error")
    func playlistNotFound() async throws {
        let args = PlaylistTool.Arguments(playlistId: "nonexistent", limit: 10)

        do {
            _ = try await self.tool.call(arguments: args)
            Issue.record("Expected error for nonexistent playlist")
        } catch {
            #expect(error is YTMusicError)
        }
    }
}

// MARK: - NowPlayingToolTests

/// Tests for NowPlayingTool output formatting and behavior.
/// Note: These tests require a mock PlayerService, so we test the tool's output formatting.
@available(macOS 26.0, *)
@Suite("NowPlayingTool Unit", .tags(.api))
struct NowPlayingToolTests {
    @Test("Tool has correct name and description")
    @MainActor
    func toolMetadata() {
        // Cannot fully test without injecting a mock PlayerService
        // This test verifies the tool can be instantiated
        let playerService = PlayerService()
        let tool = NowPlayingTool(playerService: playerService)

        #expect(tool.name == "getNowPlaying")
        #expect(tool.description.contains("currently playing"))
    }

    @Test("Tool returns no track message when nothing playing")
    @MainActor
    func noTrackPlaying() async throws {
        let playerService = PlayerService()
        let tool = NowPlayingTool(playerService: playerService)

        let args = NowPlayingTool.Arguments(includePlaybackState: false)
        let result = try await tool.call(arguments: args)

        #expect(result.contains("No track is currently playing"))
    }
}

// MARK: - QueueToolTests

/// Tests for QueueTool output formatting and behavior.
@available(macOS 26.0, *)
@Suite("QueueTool Unit", .tags(.api))
struct QueueToolTests {
    @Test("Tool has correct name and description")
    @MainActor
    func toolMetadata() {
        let playerService = PlayerService()
        let tool = QueueTool(playerService: playerService)

        #expect(tool.name == "getCurrentQueue")
        #expect(tool.description.contains("queue"))
    }

    @Test("Empty queue returns appropriate message")
    @MainActor
    func emptyQueue() async throws {
        let playerService = PlayerService()
        let tool = QueueTool(playerService: playerService)

        let args = QueueTool.Arguments(limit: 20)
        let result = try await tool.call(arguments: args)

        #expect(result.contains("Queue is empty"))
    }
}

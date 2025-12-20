import XCTest
@testable import Kaset

/// Tests for data models.
final class ModelTests: XCTestCase {
    // MARK: - Song Tests

    func testSongDurationParsingFromSeconds() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "Test Song",
            "duration_seconds": 185.0,
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertEqual(song?.duration, 185.0)
        XCTAssertEqual(song?.durationDisplay, "3:05")
    }

    func testSongDurationParsingFromString() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "Test Song",
            "duration": "4:30",
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertEqual(song?.duration, 270.0) // 4 * 60 + 30
    }

    func testSongDurationParsingHours() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "Long Song",
            "duration": "1:05:30",
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertEqual(song?.duration, 3930.0) // 1 * 3600 + 5 * 60 + 30
    }

    func testSongWithMultipleArtists() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "Collab Song",
            "artists": [
                ["name": "Artist One", "id": "A1"],
                ["name": "Artist Two", "id": "A2"],
                ["name": "Artist Three", "id": "A3"],
            ],
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertEqual(song?.artists.count, 3)
        XCTAssertEqual(song?.artistsDisplay, "Artist One, Artist Two, Artist Three")
    }

    func testSongWithNoArtists() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "No Artists Song",
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertEqual(song?.artists.count, 0)
        XCTAssertEqual(song?.artistsDisplay, "")
    }

    func testSongWithAlbum() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "Album Track",
            "album": [
                "browseId": "album123",
                "title": "Test Album",
            ],
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertNotNil(song?.album)
        XCTAssertEqual(song?.album?.title, "Test Album")
    }

    func testSongWithThumbnails() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "Thumbnail Song",
            "thumbnails": [
                ["url": "https://example.com/small.jpg", "width": 60, "height": 60],
                ["url": "https://example.com/large.jpg", "width": 400, "height": 400],
            ],
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        // Should use the last (largest) thumbnail
        XCTAssertEqual(song?.thumbnailURL?.absoluteString, "https://example.com/large.jpg")
    }

    func testSongDefaultTitle() {
        let data: [String: Any] = [
            "videoId": "test123",
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertEqual(song?.title, "Unknown Title")
    }

    func testSongNoDuration() {
        let data: [String: Any] = [
            "videoId": "test123",
            "title": "No Duration",
        ]

        let song = Song(from: data)
        XCTAssertNotNil(song)
        XCTAssertNil(song?.duration)
        XCTAssertEqual(song?.durationDisplay, "--:--")
    }

    func testSongHashable() {
        let song1 = Song(
            id: "test",
            title: "Test",
            artists: [],
            album: nil,
            duration: nil,
            thumbnailURL: nil,
            videoId: "test"
        )

        let song2 = Song(
            id: "test",
            title: "Test",
            artists: [],
            album: nil,
            duration: nil,
            thumbnailURL: nil,
            videoId: "test"
        )

        XCTAssertEqual(song1, song2)

        var set: Set<Song> = []
        set.insert(song1)
        set.insert(song2)
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - Playlist Tests

    func testPlaylistIsAlbumWithOLAK() {
        let playlist = Playlist(
            id: "OLAK5uy_abc",
            title: "Album Title",
            description: nil,
            thumbnailURL: nil,
            trackCount: 10,
            author: nil
        )

        XCTAssertTrue(playlist.isAlbum)
    }

    func testPlaylistIsAlbumWithMPRE() {
        let playlist = Playlist(
            id: "MPREb_xyz123",
            title: "Album Title",
            description: nil,
            thumbnailURL: nil,
            trackCount: 10,
            author: nil
        )

        XCTAssertTrue(playlist.isAlbum)
    }

    func testPlaylistNotAlbum() {
        let playlist = Playlist(
            id: "PLtest123",
            title: "Playlist Title",
            description: nil,
            thumbnailURL: nil,
            trackCount: 50,
            author: nil
        )

        XCTAssertFalse(playlist.isAlbum)
    }

    func testPlaylistTrackCountDisplay() {
        let playlist1 = Playlist(
            id: "PL1",
            title: "One Song",
            description: nil,
            thumbnailURL: nil,
            trackCount: 1,
            author: nil
        )
        XCTAssertEqual(playlist1.trackCountDisplay, "1 song")

        let playlist2 = Playlist(
            id: "PL2",
            title: "Many Songs",
            description: nil,
            thumbnailURL: nil,
            trackCount: 25,
            author: nil
        )
        XCTAssertEqual(playlist2.trackCountDisplay, "25 songs")

        let playlist3 = Playlist(
            id: "PL3",
            title: "No Count",
            description: nil,
            thumbnailURL: nil,
            trackCount: nil,
            author: nil
        )
        XCTAssertEqual(playlist3.trackCountDisplay, "")
    }

    func testPlaylistParsingWithBrowseId() {
        let data: [String: Any] = [
            "browseId": "browse123",
            "title": "Browse Playlist",
        ]

        let playlist = Playlist(from: data)
        XCTAssertNotNil(playlist)
        XCTAssertEqual(playlist?.id, "browse123")
    }

    func testPlaylistParsingWithAuthors() {
        let data: [String: Any] = [
            "playlistId": "PL123",
            "title": "Authored Playlist",
            "authors": [
                ["name": "Playlist Creator"],
            ],
        ]

        let playlist = Playlist(from: data)
        XCTAssertNotNil(playlist)
        XCTAssertEqual(playlist?.author, "Playlist Creator")
    }

    func testPlaylistParsingWithAuthorString() {
        let data: [String: Any] = [
            "playlistId": "PL123",
            "title": "Authored Playlist",
            "author": "Direct Author",
        ]

        let playlist = Playlist(from: data)
        XCTAssertNotNil(playlist)
        XCTAssertEqual(playlist?.author, "Direct Author")
    }

    func testPlaylistParsingTrackCountString() {
        let data: [String: Any] = [
            "playlistId": "PL123",
            "title": "Playlist",
            "trackCount": "1,234",
        ]

        let playlist = Playlist(from: data)
        XCTAssertNotNil(playlist)
        XCTAssertEqual(playlist?.trackCount, 1234)
    }

    func testPlaylistWithNoId() {
        let data: [String: Any] = [
            "title": "No ID Playlist",
        ]

        let playlist = Playlist(from: data)
        XCTAssertNil(playlist)
    }

    // MARK: - PlaylistDetail Tests

    func testPlaylistDetailFromPlaylist() {
        let playlist = Playlist(
            id: "PL123",
            title: "Test Playlist",
            description: "A description",
            thumbnailURL: URL(string: "https://example.com/thumb.jpg"),
            trackCount: 5,
            author: "Test Author"
        )

        let songs = [
            Song(id: "1", title: "Song 1", artists: [], album: nil, duration: 180, thumbnailURL: nil, videoId: "v1"),
            Song(id: "2", title: "Song 2", artists: [], album: nil, duration: 200, thumbnailURL: nil, videoId: "v2"),
        ]

        let detail = PlaylistDetail(playlist: playlist, tracks: songs, duration: "6:20")

        XCTAssertEqual(detail.id, "PL123")
        XCTAssertEqual(detail.title, "Test Playlist")
        XCTAssertEqual(detail.description, "A description")
        XCTAssertEqual(detail.author, "Test Author")
        XCTAssertEqual(detail.tracks.count, 2)
        XCTAssertEqual(detail.duration, "6:20")
    }

    func testPlaylistDetailIsAlbum() {
        let albumPlaylist = Playlist(
            id: "OLAK5uy_abc",
            title: "Album",
            description: nil,
            thumbnailURL: nil,
            trackCount: 10,
            author: nil
        )

        let detail = PlaylistDetail(playlist: albumPlaylist, tracks: [])
        XCTAssertTrue(detail.isAlbum)
    }

    // MARK: - Album Tests

    func testAlbumArtistsDisplay() {
        let artists = [
            Artist(id: "a1", name: "Artist A"),
            Artist(id: "a2", name: "Artist B"),
        ]

        let album = Album(
            id: "album1",
            title: "Multi-Artist Album",
            artists: artists,
            thumbnailURL: nil,
            year: "2024",
            trackCount: 12
        )

        XCTAssertEqual(album.artistsDisplay, "Artist A, Artist B")
    }

    func testAlbumNoArtistsDisplay() {
        let album = Album(
            id: "album1",
            title: "No Artist Album",
            artists: nil,
            thumbnailURL: nil,
            year: "2024",
            trackCount: 12
        )

        XCTAssertEqual(album.artistsDisplay, "")
    }

    func testAlbumParsingWithAlbumId() {
        let data: [String: Any] = [
            "albumId": "ALBUM123",
            "title": "Album via albumId",
        ]

        let album = Album(from: data)
        XCTAssertNotNil(album)
        XCTAssertEqual(album?.id, "ALBUM123")
    }

    func testAlbumParsingWithId() {
        let data: [String: Any] = [
            "id": "ID123",
            "title": "Album via id",
        ]

        let album = Album(from: data)
        XCTAssertNotNil(album)
        XCTAssertEqual(album?.id, "ID123")
    }

    func testAlbumParsingInlineReference() {
        // Inline album references only have a "name" field
        let data: [String: Any] = [
            "name": "Referenced Album",
        ]

        let album = Album(from: data)
        XCTAssertNotNil(album)
        XCTAssertEqual(album?.title, "Referenced Album")
        // ID should be a UUID since no ID was provided
        XCTAssertFalse(album?.id.isEmpty ?? true)
    }

    func testAlbumParsingWithArtists() {
        let data: [String: Any] = [
            "browseId": "ALBUM123",
            "title": "Album with Artists",
            "artists": [
                ["name": "Artist One", "id": "A1"],
            ],
        ]

        let album = Album(from: data)
        XCTAssertNotNil(album)
        XCTAssertEqual(album?.artists?.count, 1)
        XCTAssertEqual(album?.artists?.first?.name, "Artist One")
    }

    func testAlbumParsingWithYear() {
        let data: [String: Any] = [
            "browseId": "ALBUM123",
            "title": "Album",
            "year": "2023",
        ]

        let album = Album(from: data)
        XCTAssertNotNil(album)
        XCTAssertEqual(album?.year, "2023")
    }

    func testAlbumDefaultTitle() {
        let data: [String: Any] = [
            "browseId": "ALBUM123",
        ]

        let album = Album(from: data)
        XCTAssertNotNil(album)
        XCTAssertEqual(album?.title, "Unknown Album")
    }

    func testAlbumWithNameAsTitle() {
        let data: [String: Any] = [
            "browseId": "ALBUM123",
            "name": "Album Name",
        ]

        let album = Album(from: data)
        XCTAssertNotNil(album)
        XCTAssertEqual(album?.title, "Album Name")
    }

    func testAlbumNoIdOrName() {
        let data: [String: Any] = [
            "someOther": "field",
        ]

        let album = Album(from: data)
        XCTAssertNil(album)
    }

    // MARK: - Artist Tests

    func testArtistWithThumbnail() {
        let data: [String: Any] = [
            "browseId": "UC123",
            "name": "Artist with Thumb",
            "thumbnails": [
                ["url": "https://example.com/artist.jpg"],
            ],
        ]

        let artist = Artist(from: data)
        XCTAssertNotNil(artist)
        XCTAssertEqual(artist?.thumbnailURL?.absoluteString, "https://example.com/artist.jpg")
    }

    func testArtistWithId() {
        let data: [String: Any] = [
            "id": "ID123",
            "name": "Artist via id",
        ]

        let artist = Artist(from: data)
        XCTAssertNotNil(artist)
        XCTAssertEqual(artist?.id, "ID123")
    }

    func testArtistWithBrowseId() {
        let data: [String: Any] = [
            "browseId": "UC456",
            "name": "Artist via browseId",
        ]

        let artist = Artist(from: data)
        XCTAssertNotNil(artist)
        XCTAssertEqual(artist?.id, "UC456")
    }

    func testArtistFallbackId() {
        let data: [String: Any] = [
            "name": "Inline Artist",
        ]

        let artist = Artist(from: data)
        XCTAssertNotNil(artist)
        // Should have a UUID-based ID
        XCTAssertFalse(artist?.id.isEmpty ?? true)
    }

    func testArtistDefaultName() {
        let data: [String: Any] = [
            "id": "123",
        ]

        let artist = Artist(from: data)
        XCTAssertNotNil(artist)
        XCTAssertEqual(artist?.name, "Unknown Artist")
    }

    func testArtistInitializer() {
        let artist = Artist(id: "A1", name: "Test Artist", thumbnailURL: URL(string: "https://example.com/a.jpg"))

        XCTAssertEqual(artist.id, "A1")
        XCTAssertEqual(artist.name, "Test Artist")
        XCTAssertEqual(artist.thumbnailURL?.absoluteString, "https://example.com/a.jpg")
    }

    func testArtistHashable() {
        let artist1 = Artist(id: "A1", name: "Artist")
        let artist2 = Artist(id: "A1", name: "Artist")

        XCTAssertEqual(artist1, artist2)

        var set: Set<Artist> = []
        set.insert(artist1)
        set.insert(artist2)
        XCTAssertEqual(set.count, 1)
    }
}

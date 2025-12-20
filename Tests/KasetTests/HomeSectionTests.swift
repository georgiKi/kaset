import XCTest
@testable import Kaset

/// Tests for HomeSection and HomeSectionItem.
final class HomeSectionTests: XCTestCase {
    // MARK: - HomeSectionItem Tests

    func testSongItemId() {
        let song = Song(
            id: "video123",
            title: "Test Song",
            artists: [],
            album: nil,
            duration: nil,
            thumbnailURL: nil,
            videoId: "video123"
        )

        let item = HomeSectionItem.song(song)
        XCTAssertEqual(item.id, "song-video123")
    }

    func testAlbumItemId() {
        let album = Album(
            id: "album456",
            title: "Test Album",
            artists: nil,
            thumbnailURL: nil,
            year: nil,
            trackCount: nil
        )

        let item = HomeSectionItem.album(album)
        XCTAssertEqual(item.id, "album-album456")
    }

    func testPlaylistItemId() {
        let playlist = Playlist(
            id: "playlist789",
            title: "Test Playlist",
            description: nil,
            thumbnailURL: nil,
            trackCount: nil,
            author: nil
        )

        let item = HomeSectionItem.playlist(playlist)
        XCTAssertEqual(item.id, "playlist-playlist789")
    }

    func testArtistItemId() {
        let artist = Artist(id: "artist111", name: "Test Artist")

        let item = HomeSectionItem.artist(artist)
        XCTAssertEqual(item.id, "artist-artist111")
    }

    func testSongItemTitle() {
        let song = Song(
            id: "1",
            title: "Amazing Song",
            artists: [],
            album: nil,
            duration: nil,
            thumbnailURL: nil,
            videoId: "1"
        )

        let item = HomeSectionItem.song(song)
        XCTAssertEqual(item.title, "Amazing Song")
    }

    func testAlbumItemTitle() {
        let album = Album(
            id: "1",
            title: "Great Album",
            artists: nil,
            thumbnailURL: nil,
            year: nil,
            trackCount: nil
        )

        let item = HomeSectionItem.album(album)
        XCTAssertEqual(item.title, "Great Album")
    }

    func testPlaylistItemTitle() {
        let playlist = Playlist(
            id: "1",
            title: "My Playlist",
            description: nil,
            thumbnailURL: nil,
            trackCount: nil,
            author: nil
        )

        let item = HomeSectionItem.playlist(playlist)
        XCTAssertEqual(item.title, "My Playlist")
    }

    func testArtistItemTitle() {
        let artist = Artist(id: "1", name: "Famous Artist")

        let item = HomeSectionItem.artist(artist)
        XCTAssertEqual(item.title, "Famous Artist")
    }

    func testSongItemSubtitle() {
        let artists = [Artist(id: "a1", name: "Artist One"), Artist(id: "a2", name: "Artist Two")]
        let song = Song(
            id: "1",
            title: "Song",
            artists: artists,
            album: nil,
            duration: nil,
            thumbnailURL: nil,
            videoId: "1"
        )

        let item = HomeSectionItem.song(song)
        XCTAssertEqual(item.subtitle, "Artist One, Artist Two")
    }

    func testAlbumItemSubtitle() {
        let artists = [Artist(id: "a1", name: "Album Artist")]
        let album = Album(
            id: "1",
            title: "Album",
            artists: artists,
            thumbnailURL: nil,
            year: nil,
            trackCount: nil
        )

        let item = HomeSectionItem.album(album)
        XCTAssertEqual(item.subtitle, "Album Artist")
    }

    func testPlaylistItemSubtitle() {
        let playlist = Playlist(
            id: "1",
            title: "Playlist",
            description: nil,
            thumbnailURL: nil,
            trackCount: nil,
            author: "Playlist Author"
        )

        let item = HomeSectionItem.playlist(playlist)
        XCTAssertEqual(item.subtitle, "Playlist Author")
    }

    func testArtistItemSubtitle() {
        let artist = Artist(id: "1", name: "Artist")

        let item = HomeSectionItem.artist(artist)
        XCTAssertEqual(item.subtitle, "Artist")
    }

    func testSongItemThumbnailURL() {
        let url = URL(string: "https://example.com/song.jpg")
        let song = Song(
            id: "1",
            title: "Song",
            artists: [],
            album: nil,
            duration: nil,
            thumbnailURL: url,
            videoId: "1"
        )

        let item = HomeSectionItem.song(song)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testAlbumItemThumbnailURL() {
        let url = URL(string: "https://example.com/album.jpg")
        let album = Album(
            id: "1",
            title: "Album",
            artists: nil,
            thumbnailURL: url,
            year: nil,
            trackCount: nil
        )

        let item = HomeSectionItem.album(album)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testPlaylistItemThumbnailURL() {
        let url = URL(string: "https://example.com/playlist.jpg")
        let playlist = Playlist(
            id: "1",
            title: "Playlist",
            description: nil,
            thumbnailURL: url,
            trackCount: nil,
            author: nil
        )

        let item = HomeSectionItem.playlist(playlist)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testArtistItemThumbnailURL() {
        let url = URL(string: "https://example.com/artist.jpg")
        let artist = Artist(id: "1", name: "Artist", thumbnailURL: url)

        let item = HomeSectionItem.artist(artist)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testSongItemVideoId() {
        let song = Song(
            id: "1",
            title: "Song",
            artists: [],
            album: nil,
            duration: nil,
            thumbnailURL: nil,
            videoId: "playable_video"
        )

        let item = HomeSectionItem.song(song)
        XCTAssertEqual(item.videoId, "playable_video")
    }

    func testAlbumItemVideoId() {
        let album = Album(id: "1", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        let item = HomeSectionItem.album(album)
        XCTAssertNil(item.videoId)
    }

    func testPlaylistItemVideoId() {
        let playlist = Playlist(id: "1", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)
        let item = HomeSectionItem.playlist(playlist)
        XCTAssertNil(item.videoId)
    }

    func testArtistItemVideoId() {
        let artist = Artist(id: "1", name: "Artist")
        let item = HomeSectionItem.artist(artist)
        XCTAssertNil(item.videoId)
    }

    func testSongItemBrowseId() {
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        let item = HomeSectionItem.song(song)
        XCTAssertNil(item.browseId)
    }

    func testAlbumItemBrowseId() {
        let album = Album(id: "album123", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        let item = HomeSectionItem.album(album)
        XCTAssertEqual(item.browseId, "album123")
    }

    func testPlaylistItemBrowseId() {
        let playlist = Playlist(id: "playlist456", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)
        let item = HomeSectionItem.playlist(playlist)
        XCTAssertEqual(item.browseId, "playlist456")
    }

    func testArtistItemBrowseId() {
        let artist = Artist(id: "artist789", name: "Artist")
        let item = HomeSectionItem.artist(artist)
        XCTAssertEqual(item.browseId, "artist789")
    }

    func testPlaylistItemExtraction() {
        let playlist = Playlist(id: "PL1", title: "My Playlist", description: nil, thumbnailURL: nil, trackCount: 10, author: "Me")
        let item = HomeSectionItem.playlist(playlist)

        XCTAssertNotNil(item.playlist)
        XCTAssertEqual(item.playlist?.id, "PL1")
        XCTAssertEqual(item.playlist?.title, "My Playlist")
    }

    func testAlbumItemExtraction() {
        let album = Album(id: "AL1", title: "My Album", artists: nil, thumbnailURL: nil, year: "2024", trackCount: nil)
        let item = HomeSectionItem.album(album)

        XCTAssertNotNil(item.album)
        XCTAssertEqual(item.album?.id, "AL1")
        XCTAssertEqual(item.album?.title, "My Album")
    }

    func testNonPlaylistItemPlaylistExtraction() {
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        let item = HomeSectionItem.song(song)
        XCTAssertNil(item.playlist)
    }

    func testNonAlbumItemAlbumExtraction() {
        let artist = Artist(id: "1", name: "Artist")
        let item = HomeSectionItem.artist(artist)
        XCTAssertNil(item.album)
    }

    // MARK: - HomeSection Tests

    func testHomeSectionInit() {
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        let items = [HomeSectionItem.song(song)]

        let section = HomeSection(id: "section1", title: "My Section", items: items)

        XCTAssertEqual(section.id, "section1")
        XCTAssertEqual(section.title, "My Section")
        XCTAssertEqual(section.items.count, 1)
        XCTAssertFalse(section.isChart)
    }

    func testHomeSectionIsChart() {
        let section = HomeSection(id: "charts", title: "Top Charts", items: [], isChart: true)
        XCTAssertTrue(section.isChart)
    }

    // MARK: - HomeResponse Tests

    func testHomeResponseIsEmptyWithNoSections() {
        let response = HomeResponse(sections: [])
        XCTAssertTrue(response.isEmpty)
    }

    func testHomeResponseIsEmptyWithEmptyItems() {
        let section = HomeSection(id: "1", title: "Empty Section", items: [])
        let response = HomeResponse(sections: [section])
        XCTAssertTrue(response.isEmpty)
    }

    func testHomeResponseNotEmpty() {
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        let section = HomeSection(id: "1", title: "Section", items: [.song(song)])
        let response = HomeResponse(sections: [section])
        XCTAssertFalse(response.isEmpty)
    }

    func testHomeResponseEmptyStatic() {
        let empty = HomeResponse.empty
        XCTAssertTrue(empty.isEmpty)
        XCTAssertTrue(empty.sections.isEmpty)
    }
}

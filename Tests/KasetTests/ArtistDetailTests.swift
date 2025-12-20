import XCTest
@testable import Kaset

/// Tests for ArtistDetail.
final class ArtistDetailTests: XCTestCase {
    func testArtistDetailInit() {
        let artist = Artist(id: "UC123", name: "Test Artist", thumbnailURL: URL(string: "https://example.com/a.jpg"))
        let songs = [
            Song(id: "s1", title: "Song 1", artists: [artist], album: nil, duration: 180, thumbnailURL: nil, videoId: "s1"),
            Song(id: "s2", title: "Song 2", artists: [artist], album: nil, duration: 200, thumbnailURL: nil, videoId: "s2"),
        ]
        let albums = [
            Album(id: "a1", title: "Album 1", artists: [artist], thumbnailURL: nil, year: "2023", trackCount: 10),
        ]

        let detail = ArtistDetail(
            artist: artist,
            description: "A great artist",
            songs: songs,
            albums: albums,
            thumbnailURL: URL(string: "https://example.com/large.jpg")
        )

        XCTAssertEqual(detail.id, "UC123")
        XCTAssertEqual(detail.name, "Test Artist")
        XCTAssertEqual(detail.description, "A great artist")
        XCTAssertEqual(detail.songs.count, 2)
        XCTAssertEqual(detail.albums.count, 1)
        XCTAssertEqual(detail.thumbnailURL?.absoluteString, "https://example.com/large.jpg")
    }

    func testArtistDetailIdComputedProperty() {
        let artist = Artist(id: "artist_id_123", name: "Artist")
        let detail = ArtistDetail(artist: artist, description: nil, songs: [], albums: [], thumbnailURL: nil)
        XCTAssertEqual(detail.id, "artist_id_123")
    }

    func testArtistDetailNameComputedProperty() {
        let artist = Artist(id: "1", name: "Famous Artist Name")
        let detail = ArtistDetail(artist: artist, description: nil, songs: [], albums: [], thumbnailURL: nil)
        XCTAssertEqual(detail.name, "Famous Artist Name")
    }

    func testArtistDetailWithNoDescription() {
        let artist = Artist(id: "1", name: "Artist")
        let detail = ArtistDetail(artist: artist, description: nil, songs: [], albums: [], thumbnailURL: nil)
        XCTAssertNil(detail.description)
    }

    func testArtistDetailWithEmptySongsAndAlbums() {
        let artist = Artist(id: "1", name: "New Artist")
        let detail = ArtistDetail(artist: artist, description: "Just starting out", songs: [], albums: [], thumbnailURL: nil)
        XCTAssertTrue(detail.songs.isEmpty)
        XCTAssertTrue(detail.albums.isEmpty)
    }

    func testArtistDetailArtistProperty() {
        let artist = Artist(id: "UC123", name: "Artist", thumbnailURL: URL(string: "https://example.com/thumb.jpg"))
        let detail = ArtistDetail(artist: artist, description: nil, songs: [], albums: [], thumbnailURL: nil)

        XCTAssertEqual(detail.artist.id, "UC123")
        XCTAssertEqual(detail.artist.name, "Artist")
        XCTAssertNotNil(detail.artist.thumbnailURL)
    }
}

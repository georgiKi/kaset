import XCTest
@testable import Kaset

/// Tests for SearchResponse and SearchResultItem.
final class SearchResponseTests: XCTestCase {
    // MARK: - SearchResultItem Tests

    func testSongResultItemId() {
        let song = Song(id: "s1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "s1")
        let item = SearchResultItem.song(song)
        XCTAssertEqual(item.id, "song-s1")
    }

    func testAlbumResultItemId() {
        let album = Album(id: "a1", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        let item = SearchResultItem.album(album)
        XCTAssertEqual(item.id, "album-a1")
    }

    func testArtistResultItemId() {
        let artist = Artist(id: "ar1", name: "Artist")
        let item = SearchResultItem.artist(artist)
        XCTAssertEqual(item.id, "artist-ar1")
    }

    func testPlaylistResultItemId() {
        let playlist = Playlist(id: "p1", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)
        let item = SearchResultItem.playlist(playlist)
        XCTAssertEqual(item.id, "playlist-p1")
    }

    func testSongResultItemTitle() {
        let song = Song(id: "1", title: "My Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        let item = SearchResultItem.song(song)
        XCTAssertEqual(item.title, "My Song")
    }

    func testAlbumResultItemTitle() {
        let album = Album(id: "1", title: "My Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        let item = SearchResultItem.album(album)
        XCTAssertEqual(item.title, "My Album")
    }

    func testArtistResultItemTitle() {
        let artist = Artist(id: "1", name: "My Artist")
        let item = SearchResultItem.artist(artist)
        XCTAssertEqual(item.title, "My Artist")
    }

    func testPlaylistResultItemTitle() {
        let playlist = Playlist(id: "1", title: "My Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)
        let item = SearchResultItem.playlist(playlist)
        XCTAssertEqual(item.title, "My Playlist")
    }

    func testSongResultItemSubtitle() {
        let artists = [Artist(id: "a1", name: "Artist A"), Artist(id: "a2", name: "Artist B")]
        let song = Song(id: "1", title: "Song", artists: artists, album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        let item = SearchResultItem.song(song)
        XCTAssertEqual(item.subtitle, "Artist A, Artist B")
    }

    func testAlbumResultItemSubtitle() {
        let artists = [Artist(id: "a1", name: "Album Artist")]
        let album = Album(id: "1", title: "Album", artists: artists, thumbnailURL: nil, year: nil, trackCount: nil)
        let item = SearchResultItem.album(album)
        XCTAssertEqual(item.subtitle, "Album Artist")
    }

    func testArtistResultItemSubtitle() {
        let artist = Artist(id: "1", name: "Artist Name")
        let item = SearchResultItem.artist(artist)
        XCTAssertEqual(item.subtitle, "Artist")
    }

    func testPlaylistResultItemSubtitle() {
        let playlist = Playlist(id: "1", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: "Playlist Author")
        let item = SearchResultItem.playlist(playlist)
        XCTAssertEqual(item.subtitle, "Playlist Author")
    }

    func testSongResultItemThumbnailURL() {
        let url = URL(string: "https://example.com/song.jpg")
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: url, videoId: "1")
        let item = SearchResultItem.song(song)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testAlbumResultItemThumbnailURL() {
        let url = URL(string: "https://example.com/album.jpg")
        let album = Album(id: "1", title: "Album", artists: nil, thumbnailURL: url, year: nil, trackCount: nil)
        let item = SearchResultItem.album(album)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testArtistResultItemThumbnailURL() {
        let url = URL(string: "https://example.com/artist.jpg")
        let artist = Artist(id: "1", name: "Artist", thumbnailURL: url)
        let item = SearchResultItem.artist(artist)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testPlaylistResultItemThumbnailURL() {
        let url = URL(string: "https://example.com/playlist.jpg")
        let playlist = Playlist(id: "1", title: "Playlist", description: nil, thumbnailURL: url, trackCount: nil, author: nil)
        let item = SearchResultItem.playlist(playlist)
        XCTAssertEqual(item.thumbnailURL, url)
    }

    func testResultItemResultType() {
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        XCTAssertEqual(SearchResultItem.song(song).resultType, "Song")

        let album = Album(id: "1", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        XCTAssertEqual(SearchResultItem.album(album).resultType, "Album")

        let artist = Artist(id: "1", name: "Artist")
        XCTAssertEqual(SearchResultItem.artist(artist).resultType, "Artist")

        let playlist = Playlist(id: "1", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)
        XCTAssertEqual(SearchResultItem.playlist(playlist).resultType, "Playlist")
    }

    func testSongResultItemVideoId() {
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "video123")
        let item = SearchResultItem.song(song)
        XCTAssertEqual(item.videoId, "video123")
    }

    func testNonSongResultItemVideoId() {
        let album = Album(id: "1", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        XCTAssertNil(SearchResultItem.album(album).videoId)

        let artist = Artist(id: "1", name: "Artist")
        XCTAssertNil(SearchResultItem.artist(artist).videoId)

        let playlist = Playlist(id: "1", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)
        XCTAssertNil(SearchResultItem.playlist(playlist).videoId)
    }

    // MARK: - SearchResponse Tests

    func testSearchResponseEmpty() {
        let response = SearchResponse.empty
        XCTAssertTrue(response.isEmpty)
        XCTAssertTrue(response.songs.isEmpty)
        XCTAssertTrue(response.albums.isEmpty)
        XCTAssertTrue(response.artists.isEmpty)
        XCTAssertTrue(response.playlists.isEmpty)
        XCTAssertTrue(response.allItems.isEmpty)
    }

    func testSearchResponseIsEmpty() {
        let empty = SearchResponse(songs: [], albums: [], artists: [], playlists: [])
        XCTAssertTrue(empty.isEmpty)
    }

    func testSearchResponseNotEmptyWithSongs() {
        let song = Song(id: "1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "1")
        let response = SearchResponse(songs: [song], albums: [], artists: [], playlists: [])
        XCTAssertFalse(response.isEmpty)
    }

    func testSearchResponseNotEmptyWithAlbums() {
        let album = Album(id: "1", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        let response = SearchResponse(songs: [], albums: [album], artists: [], playlists: [])
        XCTAssertFalse(response.isEmpty)
    }

    func testSearchResponseNotEmptyWithArtists() {
        let artist = Artist(id: "1", name: "Artist")
        let response = SearchResponse(songs: [], albums: [], artists: [artist], playlists: [])
        XCTAssertFalse(response.isEmpty)
    }

    func testSearchResponseNotEmptyWithPlaylists() {
        let playlist = Playlist(id: "1", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)
        let response = SearchResponse(songs: [], albums: [], artists: [], playlists: [playlist])
        XCTAssertFalse(response.isEmpty)
    }

    func testSearchResponseAllItems() {
        let song = Song(id: "s1", title: "Song", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "s1")
        let album = Album(id: "a1", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)
        let artist = Artist(id: "ar1", name: "Artist")
        let playlist = Playlist(id: "p1", title: "Playlist", description: nil, thumbnailURL: nil, trackCount: nil, author: nil)

        let response = SearchResponse(songs: [song], albums: [album], artists: [artist], playlists: [playlist])

        let allItems = response.allItems
        XCTAssertEqual(allItems.count, 4)

        // Check that items are in expected order: songs, albums, artists, playlists
        XCTAssertEqual(allItems[0].id, "song-s1")
        XCTAssertEqual(allItems[1].id, "album-a1")
        XCTAssertEqual(allItems[2].id, "artist-ar1")
        XCTAssertEqual(allItems[3].id, "playlist-p1")
    }

    func testSearchResponseAllItemsMultiple() {
        let song1 = Song(id: "s1", title: "Song 1", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "s1")
        let song2 = Song(id: "s2", title: "Song 2", artists: [], album: nil, duration: nil, thumbnailURL: nil, videoId: "s2")
        let album = Album(id: "a1", title: "Album", artists: nil, thumbnailURL: nil, year: nil, trackCount: nil)

        let response = SearchResponse(songs: [song1, song2], albums: [album], artists: [], playlists: [])

        XCTAssertEqual(response.allItems.count, 3)
    }
}

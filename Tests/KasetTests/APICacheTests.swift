import XCTest
@testable import Kaset

/// Tests for APICache.
@MainActor
final class APICacheTests: XCTestCase {
    var cache: APICache!

    override func setUp() async throws {
        cache = APICache.shared
        cache.invalidateAll()
    }

    override func tearDown() async throws {
        cache.invalidateAll()
        cache = nil
    }

    func testCacheSetAndGet() {
        let data: [String: Any] = ["key": "value", "number": 42]
        cache.set(key: "test_key", data: data, ttl: 60)

        let retrieved = cache.get(key: "test_key")
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?["key"] as? String, "value")
        XCTAssertEqual(retrieved?["number"] as? Int, 42)
    }

    func testCacheGetNonexistent() {
        let retrieved = cache.get(key: "nonexistent_key")
        XCTAssertNil(retrieved)
    }

    func testCacheInvalidateAll() {
        cache.set(key: "key1", data: ["a": 1], ttl: 60)
        cache.set(key: "key2", data: ["b": 2], ttl: 60)

        XCTAssertNotNil(cache.get(key: "key1"))
        XCTAssertNotNil(cache.get(key: "key2"))

        cache.invalidateAll()

        XCTAssertNil(cache.get(key: "key1"))
        XCTAssertNil(cache.get(key: "key2"))
    }

    func testCacheInvalidateMatchingPrefix() {
        cache.set(key: "home_section1", data: ["a": 1], ttl: 60)
        cache.set(key: "home_section2", data: ["b": 2], ttl: 60)
        cache.set(key: "search_results", data: ["c": 3], ttl: 60)

        cache.invalidate(matching: "home_")

        XCTAssertNil(cache.get(key: "home_section1"))
        XCTAssertNil(cache.get(key: "home_section2"))
        XCTAssertNotNil(cache.get(key: "search_results"))
    }

    func testCacheEntryExpiration() async throws {
        // Set with a very short TTL
        cache.set(key: "short_lived", data: ["test": true], ttl: 0.1)

        // Should exist immediately
        XCTAssertNotNil(cache.get(key: "short_lived"))

        // Wait for expiration
        try await Task.sleep(for: .milliseconds(150))

        // Should be expired
        XCTAssertNil(cache.get(key: "short_lived"))
    }

    func testCacheOverwrite() {
        cache.set(key: "key", data: ["value": 1], ttl: 60)
        XCTAssertEqual(cache.get(key: "key")?["value"] as? Int, 1)

        cache.set(key: "key", data: ["value": 2], ttl: 60)
        XCTAssertEqual(cache.get(key: "key")?["value"] as? Int, 2)
    }

    func testCacheTTLConstants() {
        XCTAssertEqual(APICache.TTL.home, 5 * 60) // 5 minutes
        XCTAssertEqual(APICache.TTL.playlist, 30 * 60) // 30 minutes
        XCTAssertEqual(APICache.TTL.artist, 60 * 60) // 1 hour
        XCTAssertEqual(APICache.TTL.search, 2 * 60) // 2 minutes
    }

    func testCacheEntryIsExpired() {
        let freshEntry = APICache.CacheEntry(
            data: [:],
            timestamp: Date(),
            ttl: 60
        )
        XCTAssertFalse(freshEntry.isExpired)

        let expiredEntry = APICache.CacheEntry(
            data: [:],
            timestamp: Date().addingTimeInterval(-120),
            ttl: 60
        )
        XCTAssertTrue(expiredEntry.isExpired)
    }

    func testCacheSharedInstance() {
        XCTAssertNotNil(APICache.shared)
        // Test that it's truly a singleton
        let instance1 = APICache.shared
        let instance2 = APICache.shared
        XCTAssertTrue(instance1 === instance2)
    }
}

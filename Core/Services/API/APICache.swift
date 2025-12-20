import Foundation

/// Thread-safe cache for API responses with TTL support.
/// Uses @MainActor since YTMusicClient is also @MainActor.
@MainActor
final class APICache {
    static let shared = APICache()

    struct CacheEntry {
        let data: [String: Any]
        let timestamp: Date
        let ttl: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }

    /// TTL values for different endpoint types.
    enum TTL {
        static let home: TimeInterval = 5 * 60 // 5 minutes
        static let playlist: TimeInterval = 30 * 60 // 30 minutes
        static let artist: TimeInterval = 60 * 60 // 1 hour
        static let search: TimeInterval = 2 * 60 // 2 minutes
    }

    private var cache: [String: CacheEntry] = [:]

    private init() {}

    /// Gets cached data if available and not expired.
    func get(key: String) -> [String: Any]? {
        guard let entry = cache[key], !entry.isExpired else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry.data
    }

    /// Stores data in the cache with the specified TTL.
    func set(key: String, data: [String: Any], ttl: TimeInterval) {
        cache[key] = CacheEntry(data: data, timestamp: Date(), ttl: ttl)
    }

    /// Invalidates all cached entries.
    func invalidateAll() {
        cache.removeAll()
    }

    /// Invalidates entries matching the given prefix.
    func invalidate(matching prefix: String) {
        cache = cache.filter { !$0.key.hasPrefix(prefix) }
    }
}

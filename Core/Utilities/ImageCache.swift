import AppKit
import Foundation

/// Thread-safe image cache with memory limits.
actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, NSImage>()
    private var inFlight: [URL: Task<NSImage?, Never>] = [:]

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    /// Fetches an image from cache or network.
    func image(for url: URL) async -> NSImage? {
        // Check memory cache
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }

        // Check if already fetching
        if let existing = inFlight[url] {
            return await existing.value
        }

        // Fetch
        let task = Task<NSImage?, Never> {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = NSImage(data: data) else { return nil }
                cache.setObject(image, forKey: url as NSURL, cost: data.count)
                return image
            } catch {
                return nil
            }
        }

        inFlight[url] = task
        let result = await task.value
        inFlight.removeValue(forKey: url)
        return result
    }

    /// Clears the cache.
    func clearCache() {
        cache.removeAllObjects()
        inFlight.removeAll()
    }
}

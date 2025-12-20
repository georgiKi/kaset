import XCTest
@testable import Kaset

/// Tests for utility extensions.
final class ExtensionsTests: XCTestCase {
    // MARK: - Collection Safe Subscript Tests

    func testArraySafeSubscriptInBounds() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 2], 3)
        XCTAssertEqual(array[safe: 4], 5)
    }

    func testArraySafeSubscriptOutOfBounds() {
        let array = [1, 2, 3]
        XCTAssertNil(array[safe: 3])
        XCTAssertNil(array[safe: 10])
        XCTAssertNil(array[safe: -1])
    }

    func testArraySafeSubscriptEmptyArray() {
        let array: [Int] = []
        XCTAssertNil(array[safe: 0])
    }

    func testStringSafeSubscript() {
        let string = "Hello"
        let array = Array(string)
        XCTAssertEqual(array[safe: 0], "H")
        XCTAssertEqual(array[safe: 4], "o")
        XCTAssertNil(array[safe: 5])
    }

    // MARK: - TimeInterval Formatted Duration Tests

    func testFormattedDurationSeconds() {
        XCTAssertEqual(TimeInterval(0).formattedDuration, "0:00")
        XCTAssertEqual(TimeInterval(5).formattedDuration, "0:05")
        XCTAssertEqual(TimeInterval(59).formattedDuration, "0:59")
    }

    func testFormattedDurationMinutes() {
        XCTAssertEqual(TimeInterval(60).formattedDuration, "1:00")
        XCTAssertEqual(TimeInterval(65).formattedDuration, "1:05")
        XCTAssertEqual(TimeInterval(125).formattedDuration, "2:05")
        XCTAssertEqual(TimeInterval(3599).formattedDuration, "59:59")
    }

    func testFormattedDurationHours() {
        XCTAssertEqual(TimeInterval(3600).formattedDuration, "1:00:00")
        XCTAssertEqual(TimeInterval(3661).formattedDuration, "1:01:01")
        XCTAssertEqual(TimeInterval(7325).formattedDuration, "2:02:05")
        XCTAssertEqual(TimeInterval(36000).formattedDuration, "10:00:00")
    }

    func testFormattedDurationDecimal() {
        // Should truncate to integer seconds
        XCTAssertEqual(TimeInterval(65.5).formattedDuration, "1:05")
        XCTAssertEqual(TimeInterval(65.9).formattedDuration, "1:05")
    }

    // MARK: - URL High Quality Thumbnail Tests

    func testHighQualityThumbnailYtimg() {
        let url = URL(string: "https://i.ytimg.com/vi/abc/w60-h60-l90-rj")!
        let highQuality = url.highQualityThumbnailURL
        XCTAssertNotNil(highQuality)
        XCTAssertTrue(highQuality!.absoluteString.contains("w226-h226"))
    }

    func testHighQualityThumbnailGoogleusercontent() {
        let url = URL(string: "https://lh3.googleusercontent.com/abc=w120-h120-l90-rj")!
        let highQuality = url.highQualityThumbnailURL
        XCTAssertNotNil(highQuality)
        XCTAssertTrue(highQuality!.absoluteString.contains("w226-h226"))
    }

    func testHighQualityThumbnailNonYouTubeURL() {
        let url = URL(string: "https://example.com/image.jpg")!
        let highQuality = url.highQualityThumbnailURL
        XCTAssertEqual(highQuality, url) // Should return original URL
    }

    func testHighQualityThumbnailAlreadyHighQuality() {
        let url = URL(string: "https://i.ytimg.com/vi/abc/w400-h400-l90-rj")!
        let highQuality = url.highQualityThumbnailURL
        // Should return the same URL since it doesn't contain w60-h60 or w120-h120
        XCTAssertEqual(highQuality?.absoluteString, "https://i.ytimg.com/vi/abc/w400-h400-l90-rj")
    }

    // MARK: - String Truncated Tests

    func testStringTruncatedShorterThanLimit() {
        let string = "Hello"
        XCTAssertEqual(string.truncated(to: 10), "Hello")
    }

    func testStringTruncatedExactlyAtLimit() {
        let string = "Hello"
        XCTAssertEqual(string.truncated(to: 5), "Hello")
    }

    func testStringTruncatedLongerThanLimit() {
        let string = "Hello, World!"
        XCTAssertEqual(string.truncated(to: 5), "Hello…")
    }

    func testStringTruncatedWithCustomTrailing() {
        let string = "Hello, World!"
        XCTAssertEqual(string.truncated(to: 5, trailing: "..."), "Hello...")
    }

    func testStringTruncatedEmptyString() {
        let string = ""
        XCTAssertEqual(string.truncated(to: 10), "")
    }

    func testStringTruncatedZeroLength() {
        let string = "Hello"
        XCTAssertEqual(string.truncated(to: 0), "…")
    }

    func testStringTruncatedOneCharacter() {
        let string = "Hello"
        XCTAssertEqual(string.truncated(to: 1), "H…")
    }
}

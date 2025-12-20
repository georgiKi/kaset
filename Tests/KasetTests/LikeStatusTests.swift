import XCTest
@testable import Kaset

/// Unit tests for LikeStatus and FeedbackTokens.
final class LikeStatusTests: XCTestCase {
    // MARK: - LikeStatus Tests

    func testLikeStatusRawValues() {
        XCTAssertEqual(LikeStatus.like.rawValue, "LIKE")
        XCTAssertEqual(LikeStatus.dislike.rawValue, "DISLIKE")
        XCTAssertEqual(LikeStatus.indifferent.rawValue, "INDIFFERENT")
    }

    func testLikeStatusIsLiked() {
        XCTAssertTrue(LikeStatus.like.isLiked)
        XCTAssertFalse(LikeStatus.dislike.isLiked)
        XCTAssertFalse(LikeStatus.indifferent.isLiked)
    }

    func testLikeStatusIsDisliked() {
        XCTAssertFalse(LikeStatus.like.isDisliked)
        XCTAssertTrue(LikeStatus.dislike.isDisliked)
        XCTAssertFalse(LikeStatus.indifferent.isDisliked)
    }

    func testLikeStatusEncodingDecoding() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for status in [LikeStatus.like, .dislike, .indifferent] {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(LikeStatus.self, from: data)
            XCTAssertEqual(status, decoded)
        }
    }

    func testLikeStatusDecodingFromRawValue() throws {
        let decoder = JSONDecoder()

        let likeData = Data("\"LIKE\"".utf8)
        let likeStatus = try decoder.decode(LikeStatus.self, from: likeData)
        XCTAssertEqual(likeStatus, .like)

        let dislikeData = Data("\"DISLIKE\"".utf8)
        let dislikeStatus = try decoder.decode(LikeStatus.self, from: dislikeData)
        XCTAssertEqual(dislikeStatus, .dislike)

        let indifferentData = Data("\"INDIFFERENT\"".utf8)
        let indifferentStatus = try decoder.decode(LikeStatus.self, from: indifferentData)
        XCTAssertEqual(indifferentStatus, .indifferent)
    }

    func testLikeStatusEquality() {
        XCTAssertEqual(LikeStatus.like, LikeStatus.like)
        XCTAssertNotEqual(LikeStatus.like, LikeStatus.dislike)
        XCTAssertNotEqual(LikeStatus.like, LikeStatus.indifferent)
        XCTAssertNotEqual(LikeStatus.dislike, LikeStatus.indifferent)
    }

    // MARK: - FeedbackTokens Tests

    func testFeedbackTokensInitialization() {
        let tokens = FeedbackTokens(add: "add_token_123", remove: "remove_token_456")
        XCTAssertEqual(tokens.add, "add_token_123")
        XCTAssertEqual(tokens.remove, "remove_token_456")
    }

    func testFeedbackTokensWithNilValues() {
        let tokensNilAdd = FeedbackTokens(add: nil, remove: "remove_token")
        XCTAssertNil(tokensNilAdd.add)
        XCTAssertEqual(tokensNilAdd.remove, "remove_token")

        let tokensNilRemove = FeedbackTokens(add: "add_token", remove: nil)
        XCTAssertEqual(tokensNilRemove.add, "add_token")
        XCTAssertNil(tokensNilRemove.remove)

        let tokensAllNil = FeedbackTokens(add: nil, remove: nil)
        XCTAssertNil(tokensAllNil.add)
        XCTAssertNil(tokensAllNil.remove)
    }

    func testFeedbackTokensTokenForAdding() {
        let tokens = FeedbackTokens(add: "add_token", remove: "remove_token")

        XCTAssertEqual(tokens.token(forAdding: true), "add_token")
        XCTAssertEqual(tokens.token(forAdding: false), "remove_token")
    }

    func testFeedbackTokensTokenForAddingWithNilValues() {
        let tokensNilAdd = FeedbackTokens(add: nil, remove: "remove_token")
        XCTAssertNil(tokensNilAdd.token(forAdding: true))
        XCTAssertEqual(tokensNilAdd.token(forAdding: false), "remove_token")

        let tokensNilRemove = FeedbackTokens(add: "add_token", remove: nil)
        XCTAssertEqual(tokensNilRemove.token(forAdding: true), "add_token")
        XCTAssertNil(tokensNilRemove.token(forAdding: false))
    }

    func testFeedbackTokensEncodingDecoding() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let tokens = FeedbackTokens(add: "add_token_123", remove: "remove_token_456")
        let data = try encoder.encode(tokens)
        let decoded = try decoder.decode(FeedbackTokens.self, from: data)

        XCTAssertEqual(tokens.add, decoded.add)
        XCTAssertEqual(tokens.remove, decoded.remove)
    }

    func testFeedbackTokensEquality() {
        let tokens1 = FeedbackTokens(add: "add", remove: "remove")
        let tokens2 = FeedbackTokens(add: "add", remove: "remove")
        let tokens3 = FeedbackTokens(add: "different", remove: "remove")

        XCTAssertEqual(tokens1, tokens2)
        XCTAssertNotEqual(tokens1, tokens3)
    }

    func testFeedbackTokensHashable() {
        let tokens1 = FeedbackTokens(add: "add", remove: "remove")
        let tokens2 = FeedbackTokens(add: "add", remove: "remove")

        var set = Set<FeedbackTokens>()
        set.insert(tokens1)
        set.insert(tokens2)

        XCTAssertEqual(set.count, 1)
    }
}

import XCTest
@testable import Kaset

/// Tests for RetryPolicy.
final class RetryPolicyTests: XCTestCase {
    func testDefaultPolicyValues() {
        let policy = RetryPolicy.default
        XCTAssertEqual(policy.maxAttempts, 3)
        XCTAssertEqual(policy.baseDelay, 1.0)
        XCTAssertEqual(policy.maxDelay, 8.0)
    }

    func testDelayExponentialBackoff() {
        let policy = RetryPolicy(maxAttempts: 5, baseDelay: 1.0, maxDelay: 16.0)

        XCTAssertEqual(policy.delay(for: 0), 1.0) // 1 * 2^0 = 1
        XCTAssertEqual(policy.delay(for: 1), 2.0) // 1 * 2^1 = 2
        XCTAssertEqual(policy.delay(for: 2), 4.0) // 1 * 2^2 = 4
        XCTAssertEqual(policy.delay(for: 3), 8.0) // 1 * 2^3 = 8
        XCTAssertEqual(policy.delay(for: 4), 16.0) // 1 * 2^4 = 16
    }

    func testDelayMaxCap() {
        let policy = RetryPolicy(maxAttempts: 10, baseDelay: 1.0, maxDelay: 8.0)

        // Should cap at maxDelay
        XCTAssertEqual(policy.delay(for: 5), 8.0) // Would be 32, but capped at 8
        XCTAssertEqual(policy.delay(for: 10), 8.0) // Would be 1024, but capped at 8
    }

    func testDelayWithCustomBaseDelay() {
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0.5, maxDelay: 10.0)

        XCTAssertEqual(policy.delay(for: 0), 0.5) // 0.5 * 2^0 = 0.5
        XCTAssertEqual(policy.delay(for: 1), 1.0) // 0.5 * 2^1 = 1.0
        XCTAssertEqual(policy.delay(for: 2), 2.0) // 0.5 * 2^2 = 2.0
    }

    func testCustomPolicyInit() {
        let policy = RetryPolicy(maxAttempts: 5, baseDelay: 2.0, maxDelay: 30.0)
        XCTAssertEqual(policy.maxAttempts, 5)
        XCTAssertEqual(policy.baseDelay, 2.0)
        XCTAssertEqual(policy.maxDelay, 30.0)
    }

    @MainActor
    func testExecuteSuccess() async throws {
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)

        var callCount = 0
        let result = try await policy.execute {
            callCount += 1
            return "success"
        }

        XCTAssertEqual(result, "success")
        XCTAssertEqual(callCount, 1)
    }

    @MainActor
    func testExecuteSuccessAfterRetries() async throws {
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)

        var callCount = 0
        let result = try await policy.execute {
            callCount += 1
            if callCount < 3 {
                throw YTMusicError.networkError(underlying: URLError(.timedOut))
            }
            return "success"
        }

        XCTAssertEqual(result, "success")
        XCTAssertEqual(callCount, 3)
    }

    @MainActor
    func testExecuteFailsAfterMaxAttempts() async {
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)

        var callCount = 0
        do {
            _ = try await policy.execute { () -> String in
                callCount += 1
                throw YTMusicError.networkError(underlying: URLError(.timedOut))
            }
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(callCount, 3)
            if case YTMusicError.networkError = error {
                // Expected
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }

    @MainActor
    func testExecuteDoesNotRetryAuthExpired() async {
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)

        var callCount = 0
        do {
            _ = try await policy.execute { () -> String in
                callCount += 1
                throw YTMusicError.authExpired
            }
            XCTFail("Should have thrown")
        } catch YTMusicError.authExpired {
            XCTAssertEqual(callCount, 1) // Should not retry
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    @MainActor
    func testExecuteDoesNotRetryNotAuthenticated() async {
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)

        var callCount = 0
        do {
            _ = try await policy.execute { () -> String in
                callCount += 1
                throw YTMusicError.notAuthenticated
            }
            XCTFail("Should have thrown")
        } catch YTMusicError.notAuthenticated {
            XCTAssertEqual(callCount, 1) // Should not retry
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}

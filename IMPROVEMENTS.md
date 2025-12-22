# Kaset Improvements Plan

Improvements for existing functionality focused on **polish, performance, and stability**.

Based on analysis of [swiftwithmajid.com](https://swiftwithmajid.com) articles and current codebase patterns.

---

## 🔴 Critical - Stability & Error Handling

### 1. Replace Custom `ErrorView` with `ContentUnavailableView`

**Status:** ✅ Completed
**Effort:** Low
**Impact:** Better UX, platform-native styling

Updated `ErrorView` in `Views/macOS/SharedViews/ErrorView.swift` to use `ContentUnavailableView` internally. All views that use `ErrorView` now get the native platform styling automatically.

---

### 2. Add `Task.checkCancellation()` After Async Calls

**Status:** ✅ Completed
**Effort:** Low
**Impact:** Better resource cleanup, prevents unnecessary work

Updated `SearchViewModel` and `HomeViewModel` to use `try Task.checkCancellation()` after async operations.

**Files updated:**
- `Core/ViewModels/SearchViewModel.swift`
- `Core/ViewModels/HomeViewModel.swift`

---

## 🟡 High Priority - Performance

### 3. Use `withTaskGroup` for Parallel Operations

**Status:** ✅ Already Implemented
**Effort:** Medium
**Impact:** Faster loading, better resource utilization

`HomeViewModel` and `ImageCache.prefetch` already use `TaskGroup` for parallel operations.

---

### 4. Add Memory Pressure Handling to `ImageCache`

**Status:** ✅ Completed
**Effort:** Low
**Impact:** Prevents memory-related crashes

Added `DispatchSource.makeMemoryPressureSource` monitoring to clear memory cache on system memory warnings.

**File:** `Core/Utilities/ImageCache.swift`

---

### 5. Ensure Seek/Volume Only Fire on Drag End

**Status:** ✅ Already Implemented
**Effort:** Low
**Impact:** Reduces unnecessary API calls

Verified: `PlayerBar` uses local state for smooth UI and only calls `performSeek()` / `performVolumeChange()` when slider editing ends.

**File:** `Views/macOS/PlayerBar.swift`

---

## 🟢 Medium Priority - Polish

### 6. Add Logging Privacy Annotations

**Status:** Not started
**Effort:** Low
**Impact:** Security compliance, proper log redaction

Requires review of all logging call sites to add appropriate privacy annotations.

---

### 7. Use `.searchScopes` for Search Filters

**Status:** Deferred
**Effort:** Medium
**Impact:** Platform-native UX, better accessibility

The current custom search field with suggestions dropdown is not compatible with `.searchable` / `.searchScopes`. Converting would require significant refactoring. Current chip implementation works well.

---

### 8. Add Keyboard Shortcuts

**Status:** ✅ Completed
**Effort:** Low
**Impact:** Accessibility, power user support

Added media control shortcuts to `PlayerBar`:
- **Space**: Play/Pause
- **⌘→**: Next track
- **⌘←**: Previous track
- **⌘↑**: Volume up
- **⌘↓**: Volume down
- **⌘M**: Toggle mute

**File:** `Views/macOS/PlayerBar.swift`

---

## 🔵 Testing Improvements

### 9. Consider Swift Testing Framework Migration

**Status:** Not started
**Effort:** Medium
**Impact:** Better test ergonomics, parameterized tests

Current tests use XCTest. Swift Testing (`import Testing`) provides:
- Parameterized tests with `@Test(arguments:)`
- Better async support
- Cleaner assertions with `#expect`

**Files:** All files in `Tests/KasetTests/`

**Current XCTest pattern:**
```swift
func testLoadSuccess() async {
    await viewModel.load()
    XCTAssertEqual(viewModel.loadingState, .loaded)
}
```

**Swift Testing pattern:**
```swift
@Test("Load succeeds with valid response")
func loadSuccess() async {
    await viewModel.load()
    #expect(viewModel.loadingState == .loaded)
}

// Parameterized test
@Test(arguments: SearchViewModel.SearchFilter.allCases)
func filterApplies(filter: SearchViewModel.SearchFilter) async {
    viewModel.selectedFilter = filter
    #expect(viewModel.selectedFilter == filter)
}
```

---

### 10. Add Performance Baseline Tests

**Status:** Not started
**Effort:** Low
**Impact:** Catch performance regressions

Create baseline tests for parser performance.

**File:** `Tests/KasetTests/PerformanceTests/` (new tests)

```swift
@Test func homeParserPerformance() async throws {
    let clock = ContinuousClock()
    let elapsed = try await clock.measure {
        _ = try HomeResponseParser.parse(TestFixtures.largeHomeResponse)
    }
    #expect(elapsed < .milliseconds(100))
}
```

---

## Summary

| # | Priority | Improvement | Impact | Effort |
|---|----------|-------------|--------|--------|
| 1 | 🔴 Critical | `ContentUnavailableView` adoption | Better UX | Low |
| 2 | 🔴 Critical | `Task.checkCancellation()` | Stability | Low |
| 3 | 🟡 High | TaskGroup for parallel loading | Performance | Medium |
| 4 | 🟡 High | Memory pressure handling | Stability | Low |
| 5 | 🟡 High | Seek/volume debounce verification | Performance | Low |
| 6 | 🟢 Medium | Logging privacy annotations | Security | Low |
| 7 | 🟢 Medium | `.searchScopes` adoption | UX | Medium |
| 8 | 🟢 Medium | Keyboard shortcuts | Accessibility | Low |
| 9 | 🔵 Testing | Swift Testing migration | Ergonomics | Medium |
| 10 | 🔵 Testing | Performance baseline tests | Quality | Low |

---

## Implementation Order

Recommended order based on impact/effort ratio:

1. **Task.checkCancellation()** - Quick win, improves stability
2. **ContentUnavailableView** - Platform-native, low effort
3. **Memory pressure handling** - Prevents crashes
4. **Logging privacy** - Security compliance
5. **Keyboard shortcuts** - Accessibility win
6. **Seek/volume verification** - Quick check
7. **TaskGroup parallelization** - Performance boost
8. **Performance baseline tests** - Quality gate
9. **searchScopes** - UX polish
10. **Swift Testing migration** - Can be done incrementally

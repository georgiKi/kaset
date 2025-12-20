# Architecture & Services

This document provides detailed information about YouTube Music's architecture, services, and design patterns.

## Core Structure

The codebase follows a clean architecture pattern:

```
App/                → App entry point, AppDelegate
Core/               → Shared logic (platform-independent)
  ├── Models/       → Data types (Song, Playlist, Album, Artist, etc.)
  ├── Services/     → Business logic
  │   ├── API/      → YTMusicClient (YouTube Music API)
  │   ├── Auth/     → AuthService (login state machine)
  │   ├── Player/   → PlayerService, NowPlayingManager
  │   └── WebKit/   → WebKitManager (cookie persistence)
  ├── ViewModels/   → State management (HomeViewModel, etc.)
  └── Utilities/    → Helpers (DiagnosticsLogger, extensions)
Views/
  └── macOS/        → SwiftUI views (MainWindow, Sidebar, PlayerBar, etc.)
Tests/              → Unit tests (YouTubeMusicTests/)
```

## State Management

- **Source of Truth**: Services are `@MainActor @Observable` singletons
- **Environment Injection**: Views access services via `@Environment`
- **Cookie Persistence**: `WKWebsiteDataStore` with persistent identifier

## Key Services

### WebKitManager

**File**: `Core/Services/WebKit/WebKitManager.swift`

Manages WebKit infrastructure for the app:

- Owns a persistent `WKWebsiteDataStore` for cookie storage
- Provides cookie access via `getAllCookies()`
- Observes cookie changes via `WKHTTPCookieStoreObserver`
- Creates WebView configurations with shared data store

```swift
@MainActor @Observable
final class WebKitManager {
    static let shared = WebKitManager()
    
    func getAllCookies() async -> [HTTPCookie]
    func createWebViewConfiguration() -> WKWebViewConfiguration
}
```

### AuthService

**File**: `Core/Services/Auth/AuthService.swift`

Manages authentication state:

| State | Description |
|-------|-------------|
| `.loggedOut` | No valid session |
| `.loggingIn` | Login sheet presented |
| `.loggedIn` | Valid `__Secure-3PAPISID` cookie found |

**Key Methods**:
- `checkLoginStatus()` — Checks cookies for valid session
- `startLogin()` — Presents login sheet
- `sessionExpired()` — Handles 401/403 from API

### YTMusicClient

**File**: `Core/Services/API/YTMusicClient.swift`

Makes authenticated requests to YouTube Music's internal API:

- Computes `SAPISIDHASH` authorization per request
- Uses browser-style headers to avoid bot detection
- Throws `YTMusicError.authExpired` on 401/403

**Endpoints**:
- `getHome()` → Home page sections
- `search(query:)` → Search results
- `getLibraryPlaylists()` → User's playlists
- `getPlaylist(id:)` → Playlist details

### PlayerService

**File**: `Core/Services/Player/PlayerService.swift`

Controls audio playback via singleton WebView:

| Property | Type | Description |
|----------|------|-------------|
| `currentTrack` | `Song?` | Currently playing track |
| `isPlaying` | `Bool` | Playback state |
| `progress` | `Double` | Current position (seconds) |
| `duration` | `Double` | Track length (seconds) |
| `pendingPlayVideoId` | `String?` | Video ID to play |
| `showMiniPlayer` | `Bool` | Mini player visibility |

**Key Methods**:
- `play(videoId:)` — Loads and plays a video
- `play(song:)` — Plays a Song model
- `confirmPlaybackStarted()` — Dismisses mini player

### SingletonPlayerWebView

**File**: `Views/macOS/MiniPlayerWebView.swift`

Manages the singleton WebView for playback:

- Creates exactly ONE WebView for app lifetime
- Handles video loading with pause-before-load
- JavaScript bridge for playback state updates
- Survives window close for background audio

```swift
@MainActor
final class SingletonPlayerWebView {
    static let shared = SingletonPlayerWebView()
    
    func getWebView(webKitManager:, playerService:) -> WKWebView
    func loadVideo(videoId: String)
}
```

### NowPlayingManager

**File**: `Core/Services/Player/NowPlayingManager.swift`

System media integration:

- Updates `MPNowPlayingInfoCenter` with track info
- Registers `MPRemoteCommandCenter` handlers
- Handles media keys (play/pause, next, previous)

### AppDelegate

**File**: `App/AppDelegate.swift`

Application lifecycle management:

- Implements `NSWindowDelegate` to hide window instead of close
- Keeps app running when window is closed (`applicationShouldTerminateAfterLastWindowClosed` returns `false`)
- Handles dock icon click to reopen window

## Authentication Flow

```
App Launch
    │
    ▼
┌─────────────────┐
│ Check cookies   │──── __Secure-3PAPISID exists? ────┐
│ in WebKitManager│                                    │
└─────────────────┘                                    │
    │ No                                               │ Yes
    ▼                                                  ▼
┌─────────────────┐                          ┌─────────────────┐
│ Show LoginSheet │                          │ AuthService     │
│ (WKWebView)     │                          │ .loggedIn       │
└─────────────────┘                          └─────────────────┘
    │
    │ User signs in → cookies set
    │
    ▼
┌─────────────────┐
│ Observer fires  │
│ cookiesDidChange│
└─────────────────┘
    │
    ▼
┌─────────────────┐
│ Extract SAPISID │
│ Dismiss sheet   │
└─────────────────┘
```

## API Request Flow

```
YTMusicClient.getHome()
    │
    ▼
┌─────────────────────────────────────────────────┐
│ buildAuthHeaders()                              │
│  1. Get cookies from WebKitManager              │
│  2. Extract __Secure-3PAPISID                   │
│  3. Compute SAPISIDHASH = ts_SHA1(ts+sapi+origin)│
│  4. Build Cookie, Authorization, Origin headers │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ POST https://music.youtube.com/youtubei/v1/browse│
│ Body: { context: { client: WEB_REMIX }, ... }   │
└─────────────────────────────────────────────────┘
    │
    ├── 200 OK → Parse JSON → Return HomeResponse
    │
    └── 401/403 → Throw YTMusicError.authExpired
                  → AuthService.sessionExpired()
                  → Show LoginSheet
```

## Playback Flow

```
User clicks Play
    │
    ▼
┌─────────────────────────────────────────────────┐
│ PlayerService.play(videoId:)                    │
│  → Sets pendingPlayVideoId                      │
│  → Shows mini player toast                      │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ PersistentPlayerView appears                    │
│  → Gets singleton WebView                       │
│  → Loads music.youtube.com/watch?v={videoId}    │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ WKWebView plays audio (DRM handled by WebKit)   │
│  → JS bridge sends STATE_UPDATE messages        │
│  → PlayerService updates isPlaying, progress    │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ NowPlayingManager observes PlayerService        │
│  → Updates MPNowPlayingInfoCenter               │
│  → Registers media key handlers                 │
└─────────────────────────────────────────────────┘
```

## Background Audio Flow

```
User closes window (⌘W or red button)
    │
    ▼
┌─────────────────────────────────────────────────┐
│ AppDelegate.windowShouldClose(_:)               │
│  → Returns false (prevents close)               │
│  → Hides window instead                         │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ WebView remains alive (in singleton)            │
│  → Audio continues playing                      │
│  → Media keys still work                        │
└─────────────────────────────────────────────────┘
    │
    │ User clicks dock icon
    ▼
┌─────────────────────────────────────────────────┐
│ AppDelegate.applicationShouldHandleReopen       │
│  → Shows hidden window                          │
│  → Same WebView still playing                   │
└─────────────────────────────────────────────────┘
    │
    │ User quits (⌘Q)
    ▼
┌─────────────────────────────────────────────────┐
│ App terminates                                  │
│  → WebView destroyed → Audio stops              │
└─────────────────────────────────────────────────┘
```

## Error Handling

### YTMusicError

**File**: `Core/Models/YTMusicError.swift`

Unified error type for the app:

| Error | Description |
|-------|-------------|
| `.authExpired` | Session invalid (401/403) |
| `.networkError` | Connection failed |
| `.parseError` | JSON decoding failed |
| `.notLoggedIn` | No valid session |

### Error Flow

1. API returns 401/403 → `YTMusicClient` throws `.authExpired`
2. `AuthService.sessionExpired()` called → state becomes `.loggedOut`
3. `AuthService.needsReauth` set to `true`
4. `MainWindow` observes and presents `LoginSheet`
5. User re-authenticates → sheet dismissed, view reloads

## Logging

All services log via `DiagnosticsLogger`:

```swift
DiagnosticsLogger.player.info("Loading video: \(videoId)")
DiagnosticsLogger.auth.error("Cookie extraction failed")
```

**Categories**: `.player`, `.auth`, `.api`, `.webKit`

**Levels**: `.debug`, `.info`, `.warning`, `.error`

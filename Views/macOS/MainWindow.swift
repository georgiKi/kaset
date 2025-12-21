import SwiftUI

// MARK: - MainWindow

/// Main application window with sidebar navigation and player bar.
@available(macOS 26.0, *)
struct MainWindow: View {
    @Environment(AuthService.self) private var authService
    @Environment(PlayerService.self) private var playerService
    @Environment(WebKitManager.self) private var webKitManager

    /// Binding to navigation selection for keyboard shortcut control from parent.
    @Binding var navigationSelection: NavigationItem?

    @State private var showLoginSheet = false
    @State private var ytMusicClient: YTMusicClient?

    // MARK: - Cached ViewModels (persist across tab switches)

    @State private var homeViewModel: HomeViewModel?
    @State private var exploreViewModel: ExploreViewModel?
    @State private var searchViewModel: SearchViewModel?
    @State private var likedMusicViewModel: LikedMusicViewModel?
    @State private var libraryViewModel: LibraryViewModel?

    /// Access to the app delegate for persistent WebView.
    private var appDelegate: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }

    var body: some View {
        @Bindable var player = playerService

        ZStack(alignment: .bottomTrailing) {
            Group {
                if authService.state.isInitializing {
                    // Show loading while checking login status to avoid onboarding flash
                    initializingView
                } else if authService.state.isLoggedIn {
                    mainContent
                } else {
                    OnboardingView()
                }
            }

            // Persistent WebView - always present once a video has been requested
            // Uses a SINGLETON WebView instance that persists for the app lifetime
            // Compact size (120x68) for first-time interaction, then hidden (1x1)
            if let videoId = playerService.pendingPlayVideoId {
                ZStack(alignment: .topTrailing) {
                    PersistentPlayerView(videoId: videoId, isExpanded: playerService.showMiniPlayer)
                        .frame(
                            width: playerService.showMiniPlayer ? 120 : 1,
                            height: playerService.showMiniPlayer ? 68 : 1
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .opacity(playerService.showMiniPlayer ? 0.95 : 0)

                    if playerService.showMiniPlayer {
                        Button {
                            playerService.confirmPlaybackStarted()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.8))
                                .shadow(radius: 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Close")
                        .padding(3)
                    }
                }
                .shadow(color: playerService.showMiniPlayer ? .black.opacity(0.2) : .clear, radius: 6, y: 3)
                .padding(.trailing, playerService.showMiniPlayer ? 12 : 0)
                .padding(.bottom, playerService.showMiniPlayer ? 76 : 0)
                .allowsHitTesting(playerService.showMiniPlayer)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: playerService.showMiniPlayer)
        .sheet(isPresented: $showLoginSheet) {
            LoginSheet()
        }
        .onChange(of: authService.state) { _, newState in
            handleAuthStateChange(newState)
        }
        .onChange(of: authService.needsReauth) { _, needsReauth in
            if needsReauth {
                showLoginSheet = true
            }
        }
        .onChange(of: playerService.isPlaying) { _, isPlaying in
            // Auto-hide the WebView once playback starts
            if isPlaying, playerService.showMiniPlayer {
                playerService.confirmPlaybackStarted()
            }
        }
        .task {
            setupClient()
            NowPlayingManager.shared.configure(playerService: playerService)
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        if let client = ytMusicClient {
            HStack(spacing: 0) {
                // Main navigation content
                NavigationSplitView {
                    Sidebar(selection: $navigationSelection)
                } detail: {
                    detailView(for: navigationSelection, client: client)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Global lyrics sidebar - outside NavigationSplitView so it persists across all navigation
                Divider()
                    .opacity(playerService.showLyrics ? 1 : 0)
                    .frame(width: playerService.showLyrics ? 1 : 0)

                LyricsView(client: client)
                    .frame(width: playerService.showLyrics ? 280 : 0)
                    .opacity(playerService.showLyrics ? 1 : 0)
                    .clipped()
            }
            .animation(.easeInOut(duration: 0.2), value: playerService.showLyrics)
            .frame(minWidth: 900, minHeight: 600)
        } else {
            loadingView
        }
    }

    @ViewBuilder
    private func detailView(for item: NavigationItem?, client _: YTMusicClient) -> some View {
        Group {
            switch item {
            case .home:
                if let vm = homeViewModel {
                    HomeView(viewModel: vm)
                }
            case .explore:
                if let vm = exploreViewModel {
                    ExploreView(viewModel: vm)
                }
            case .search:
                if let vm = searchViewModel {
                    SearchView(viewModel: vm)
                }
            case .likedMusic:
                if let vm = likedMusicViewModel {
                    LikedMusicView(viewModel: vm)
                }
            case .library:
                if let vm = libraryViewModel {
                    LibraryView(viewModel: vm)
                }
            case .none:
                Text("Select an item from the sidebar")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading YouTube Music...")
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 900, minHeight: 600)
    }

    /// View shown while checking initial login status.
    private var initializingView: some View {
        VStack(spacing: 16) {
            CassetteIcon(size: 60)
                .foregroundStyle(.tint)
            ProgressView()
        }
        .frame(minWidth: 900, minHeight: 600)
    }

    // MARK: - Setup

    private func setupClient() {
        let client = YTMusicClient(
            authService: authService,
            webKitManager: webKitManager
        )
        ytMusicClient = client

        // Create view models once and cache them
        let homeVM = HomeViewModel(client: client)
        let exploreVM = ExploreViewModel(client: client)
        homeViewModel = homeVM
        exploreViewModel = exploreVM
        searchViewModel = SearchViewModel(client: client)
        likedMusicViewModel = LikedMusicViewModel(client: client)
        libraryViewModel = LibraryViewModel(client: client)

        // Start loading home content immediately (don't wait for view to appear)
        Task {
            await homeVM.load()
        }
    }

    private func handleAuthStateChange(_ state: AuthService.State) {
        switch state {
        case .initializing:
            // Still checking login status, do nothing
            break
        case .loggedOut:
            // Onboarding view handles login, no need to auto-show sheet
            break
        case .loggingIn:
            showLoginSheet = true
        case .loggedIn:
            showLoginSheet = false
        }
    }
}

// MARK: - NavigationItem

enum NavigationItem: String, Hashable, CaseIterable, Identifiable {
    case home = "Home"
    case explore = "Explore"
    case search = "Search"
    case likedMusic = "Liked Music"
    case library = "Library"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home:
            "house"
        case .explore:
            "globe"
        case .search:
            "magnifyingglass"
        case .likedMusic:
            "heart.fill"
        case .library:
            "music.note.list"
        }
    }
}

@available(macOS 26.0, *)
#Preview {
    @Previewable @State var navSelection: NavigationItem? = .home
    let authService = AuthService()
    MainWindow(navigationSelection: $navSelection)
        .environment(authService)
        .environment(PlayerService())
        .environment(WebKitManager.shared)
}

import SwiftUI

// MARK: - CachedAsyncImage

/// A cached version of AsyncImage that uses ImageCache.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                content(Image(nsImage: image))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            guard let url else { return }
            image = await ImageCache.shared.image(for: url)
        }
    }
}

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    /// Convenience initializer with default ProgressView placeholder.
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.content = content
        placeholder = { ProgressView() }
    }
}

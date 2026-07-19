import CollectionViewDistributionalLayoutSwiftUI
import Observation
import SwiftUI

@MainActor
@Observable
final class PageTabBarState {
    var pages: [Page] = []
    var position: Double = 0
    var onSelect: ((Int) -> Void)?
}

/// A distributional, horizontally scrolling page selector.
@MainActor
public struct PageTabBar: View {
    private let state: PageTabBarState
    private let spacing: CGFloat = 10
    private let horizontalInset: CGFloat = 20
    @State private var intrinsicWidth: CGFloat = 0

    public init(
        pages: [Page],
        position: Double = 0,
        onSelect: @escaping (Int) -> Void
    ) {
        let state = PageTabBarState()
        state.pages = pages
        state.position = position
        state.onSelect = onSelect
        self.state = state
    }

    init(state: PageTabBarState) {
        self.state = state
    }

    public var body: some View {
        GeometryReader { container in
            ScrollViewReader { proxy in
                DistributionalScrollView(
                    spacing: spacing,
                    horizontalInset: horizontalInset
                ) {
                    ForEach(state.pages) { page in
                        let index = index(of: page) ?? 0
                        PageTabBarItem(
                            title: page.title,
                            pageID: page.id,
                            selectionProgress: selectionProgress(for: index)
                        ) {
                            state.onSelect?(index)
                        }
                        .id(page.id)
                    }
                }
                .coordinateSpace(name: PageTabBarCoordinateSpace.name)
                .overlayPreferenceValue(PageTabBoundsPreferenceKey.self) { bounds in
                    PageTabBarIndicator(
                        bounds: bounds,
                        pageIDs: state.pages.map(\.id),
                        position: state.position
                    )
                }
                .onChange(of: selectedIndex) { _, index in
                    guard let pageID = state.pages[safe: index]?.id else { return }
                    withAnimation(.snappy) {
                        proxy.scrollTo(pageID, anchor: .center)
                    }
                }
                .mask {
                    PageTabBarEdgeMask(
                        isScrollable: intrinsicWidth > container.size.width,
                        fadeWidth: horizontalInset,
                        height: container.size.height
                    )
                }
            }
        }
        .background {
            PageTabBarIntrinsicContent(
                pages: state.pages,
                spacing: spacing,
                horizontalInset: horizontalInset
            )
        }
        .onPreferenceChange(PageTabBarIntrinsicWidthPreferenceKey.self) {
            intrinsicWidth = $0
        }
        .frame(height: 34)
        .sensoryFeedback(.selection, trigger: selectedIndex)
    }

    private var selectedIndex: Int {
        guard !state.pages.isEmpty else { return 0 }
        return min(state.pages.count - 1, max(0, Int(state.position.rounded())))
    }

    private func index(of page: Page) -> Int? {
        state.pages.firstIndex { $0.id == page.id }
    }

    private func selectionProgress(for index: Int) -> Double {
        max(0, min(1, 1 - abs(state.position - Double(index))))
    }
}

private struct PageTabBarIntrinsicContent: View {
    let pages: [Page]
    let spacing: CGFloat
    let horizontalInset: CGFloat

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(pages) { page in
                Text(page.title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .padding(.horizontal, 2)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, horizontalInset)
        .hidden()
        .background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: PageTabBarIntrinsicWidthPreferenceKey.self,
                    value: proxy.size.width
                )
            }
        }
    }
}

private struct PageTabBarEdgeMask: View {
    let isScrollable: Bool
    let fadeWidth: CGFloat
    let height: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            if isScrollable {
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: fadeWidth)
            }

            Color.black
                .frame(maxWidth: .infinity)

            if isScrollable {
                LinearGradient(
                    colors: [.black, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: fadeWidth)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: height)
    }
}

private struct PageTabBarIntrinsicWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct PageTabBarItem: View {
    let title: String
    let pageID: Page.ID
    let selectionProgress: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .padding(.horizontal, 2)
                .frame(maxHeight: .infinity)
                .anchorPreference(
                    key: PageTabBoundsPreferenceKey.self,
                    value: .bounds
                ) { [pageID: $0] }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var textColor: Color {
        Color.secondary.mix(with: .primary, by: selectionProgress)
    }
}

private struct PageTabBoundsPreferenceKey: PreferenceKey {
    static let defaultValue: [Page.ID: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [Page.ID: Anchor<CGRect>],
        nextValue: () -> [Page.ID: Anchor<CGRect>]
    ) {
        // DistributionalScrollView renders its content once for the visible
        // layout and once more in its hidden intrinsic-size measurement
        // overlay. Keep the first anchor so the indicator follows the
        // visible, scrollable item rather than the measurement copy.
        value.merge(nextValue(), uniquingKeysWith: { old, _ in old })
    }
}

private enum PageTabBarCoordinateSpace {
    static let name = "Pager.PageTabBar"
}

private struct PageTabBarIndicator: View {
    let bounds: [Page.ID: Anchor<CGRect>]
    let pageIDs: [Page.ID]
    let position: Double

    var body: some View {
        GeometryReader { proxy in
            let frames = pageIDs.compactMap { id in
                bounds[id].map { proxy[$0] }
            }
            let lowerIndex = max(0, min(frames.count - 1, Int(floor(position))))
            let upperIndex = max(0, min(frames.count - 1, Int(ceil(position))))
            let progress = position - floor(position)

            if let start = frames[safe: lowerIndex],
               let end = frames[safe: upperIndex] {
                Capsule()
                    .fill(Color.accentColor)
                    .frame(
                        width: start.width + (end.width - start.width) * progress,
                        height: 2
                    )
                    .position(
                        x: start.midX + (end.midX - start.midX) * progress,
                        y: proxy.size.height - 2
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

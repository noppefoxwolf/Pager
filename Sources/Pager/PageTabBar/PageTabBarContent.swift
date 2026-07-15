import CollectionViewDistributionalLayoutSwiftUI
import SwiftUI

struct PageTabItem: Identifiable, Equatable {
    let id: String
    let title: String
}

struct PageTabBarContent: View {
    let pages: [PageTabItem]
    let position: Double
    let onSelect: @MainActor (Int) -> Void

    @State private var textFrames: [String: CGRect] = [:]
    @State private var intrinsicWidth: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let viewportWidth = proxy.size.width

            ScrollView(.horizontal) {
                ZStack(alignment: .bottomLeading) {
                    DistributionalHStackLayout(
                        viewportWidth: viewportWidth,
                        spacing: 10,
                        horizontalInset: 20
                    ) {
                        tabItems
                    }

                    PageTabIndicator(frame: indicatorFrame)
                        .allowsHitTesting(false)
                }
                .frame(height: 34)
                .coordinateSpace(name: "PageTabBarContent")
                .background {
                    IntrinsicWidthLayout(spacing: 10, horizontalInset: 20) {
                        tabItems
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .opacity(0)
                    .allowsHitTesting(false)
                    .background {
                        GeometryReader { measurement in
                            Color.clear.preference(
                                key: IntrinsicWidthPreferenceKey.self,
                                value: measurement.size.width
                            )
                        }
                    }
                }
            }
            .scrollDisabled(intrinsicWidth <= viewportWidth)
            .scrollIndicators(.hidden)
        }
        .onPreferenceChange(PageTabItemFramePreferenceKey.self) {
            textFrames = $0
        }
        .onPreferenceChange(IntrinsicWidthPreferenceKey.self) {
            intrinsicWidth = $0
        }
        .animation(.snappy, value: pages)
    }

    @ViewBuilder
    private var tabItems: some View {
        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
            Button {
                onSelect(index)
            } label: {
                Text(page.title)
                    .font(.subheadline.weight(.bold))
                    .fixedSize()
                    .foregroundStyle(index == Int(position.rounded()) ? .primary : .secondary)
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: PageTabItemFramePreferenceKey.self,
                                value: [page.id: proxy.frame(in: .named("PageTabBarContent"))]
                            )
                        }
                    }
                    .frame(height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
        }
    }

    private var indicatorFrame: CGRect {
        guard let first = pages[safe: Int(floor(position))],
              let start = textFrames[first.id] else {
            return .zero
        }

        let nextIndex = min(Int(ceil(position)), pages.count - 1)
        guard let next = pages[safe: nextIndex],
              let end = textFrames[next.id] else {
            return CGRect(x: start.minX, y: 0, width: start.width, height: 4)
        }

        let progress = position - floor(position)
        return CGRect(
            x: start.minX + (end.minX - start.minX) * progress,
            y: 0,
            width: start.width + (end.width - start.width) * progress,
            height: 4
        )
    }
}

private struct PageTabIndicator: View {
    let frame: CGRect

    var body: some View {
        Capsule()
            .fill(.tint)
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX)
    }
}

private struct PageTabItemFramePreferenceKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct IntrinsicWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct IntrinsicWidthLayout: Layout {
    let spacing: CGFloat
    let horizontalInset: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return CGSize(
            width: sizes.reduce(0) { $0 + $1.width }
                + spacing * CGFloat(max(0, sizes.count - 1))
                + horizontalInset * 2,
            height: sizes.map(\.height).max() ?? 0
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX + horizontalInset
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            subview.place(
                at: CGPoint(x: x, y: bounds.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            x += size.width
            if index < subviews.count - 1 {
                x += spacing
            }
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

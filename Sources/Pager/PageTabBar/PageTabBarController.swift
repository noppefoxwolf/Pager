import SwiftUI
import UIKit

@MainActor
public protocol PageTabBarContentViewDelegate: AnyObject {
    func pageTabBarContentView(_ contentView: PageTabBarContentView, didSelect page: Page)
}

/// A UIKit content view embedding the SwiftUI `PageTabBar`.
@MainActor
public final class PageTabBarContentView: UIView, UIContentView {
    public weak var delegate: (any PageTabBarContentViewDelegate)?

    public var pages: [Page] = [] {
        didSet {
            state.pages = pages
            state.position = clampedPosition
        }
    }

    public var selectedPage: Page? {
        get { selectedIndex.flatMap { pages[safe: $0] } }
        set {
            guard let newValue,
                  let index = pages.firstIndex(where: { $0.id == newValue.id }) else {
                state.position = 0
                return
            }
            state.position = Double(index)
        }
    }

    public func setTransitionProgress(_ progress: Double) {
        state.position = min(maxPosition, max(0, progress))
    }

    public var configuration: UIContentConfiguration

    private let state: PageTabBarState
    private let hostedContentView: UIView & UIContentView
    private var maxPosition: Double { Double(max(0, pages.count - 1)) }
    private var clampedPosition: Double { min(maxPosition, max(0, state.position)) }
    private var selectedIndex: Int? {
        guard !pages.isEmpty else { return nil }
        return min(pages.count - 1, max(0, Int(state.position.rounded())))
    }

    public init(pages: [Page] = []) {
        let state = PageTabBarState()
        state.pages = pages
        self.state = state
        self.hostedContentView = UIHostingConfiguration {
            PageTabBar(state: state)
        }
        .makeContentView()
        self.configuration = hostedContentView.configuration
        super.init(frame: .zero)

        backgroundColor = .clear
        hostedContentView.backgroundColor = .clear
        hostedContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostedContentView)
        NSLayoutConstraint.activate([
            hostedContentView.topAnchor.constraint(equalTo: topAnchor),
            hostedContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostedContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostedContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        state.onSelect = { [weak self] index in
            guard let self, self.pages.indices.contains(index) else { return }
            self.delegate?.pageTabBarContentView(self, didSelect: self.pages[index])
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 34)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}

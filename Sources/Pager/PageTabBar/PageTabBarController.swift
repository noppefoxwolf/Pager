import SwiftUI
import UIKit

@MainActor
public protocol PageTabBarControllerDelegate: AnyObject {
    func pageTabBarController(_ controller: PageTabBarController, didSelect page: Page)
}

/// UIKit container for embedding the SwiftUI `PageTabBar` in existing controllers.
@MainActor
open class PageTabBarController: UIViewController {
    public weak var delegate: (any PageTabBarControllerDelegate)?
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

    private let state: PageTabBarState
    private let hostingController: UIHostingController<PageTabBar>
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
        hostingController = UIHostingController(rootView: PageTabBar(state: state))
        super.init(nibName: nil, bundle: nil)
        self.pages = pages
        hostingController.safeAreaRegions = []
        hostingController.view.backgroundColor = .clear
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func loadView() {
        view = PageTabBarControllerView()
        view.backgroundColor = .clear
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
        state.onSelect = { [weak self] index in
            guard let self, self.pages.indices.contains(index) else { return }
            self.delegate?.pageTabBarController(self, didSelect: self.pages[index])
        }
    }
}

private final class PageTabBarControllerView: UIView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 34)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}

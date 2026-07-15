import SwiftUI
import UIKit

public final class PageTabBar: UIView {
    weak var tabBarDelegate: (any PageTabBarDelegate)?

    private let feedbackGenerator = FeedbackGenerator()
    private var hostingController: UIHostingController<PageTabBarContent>!
    private weak var parentViewController: UIViewController?
    private var position: Double = 0

    var pages: [Page] = [] {
        didSet {
            updateContent()
        }
    }

    public init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 34)
    }

    func setIndicator(_ position: Double) {
        let clampedPosition = max(0, min(position, Double(max(pages.count - 1, 0))))
        let focusedIndex = Int(clampedPosition.rounded())

        if focusedIndex != Int(self.position.rounded()), !pages.isEmpty {
            feedbackGenerator.selectionChanged()
        }

        self.position = clampedPosition
        updateContent()
    }

    private func configure() {
        backgroundColor = .clear
        feedbackGenerator.prepare()

        let content = PageTabBarContent(
            pages: pageItems,
            position: position,
            onSelect: { [weak self] index in
                guard let self else { return }
                tabBarDelegate?.pageTabBar(self, didSelected: index)
            }
        )
        hostingController = UIHostingController(rootView: content)
        hostingController.safeAreaRegions = []
        hostingController.view.backgroundColor = .clear
        guard let parentViewController else { return }
        parentViewController.addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        hostingController.didMove(toParent: parentViewController)
    }

    private var pageItems: [PageTabItem] {
        pages
            .map { PageTabItem(id: $0.id, title: $0.title) }
    }

    private func updateContent() {
        guard hostingController != nil else { return }
        hostingController.rootView = PageTabBarContent(
            pages: pageItems,
            position: position,
            onSelect: { [weak self] index in
                guard let self else { return }
                tabBarDelegate?.pageTabBar(self, didSelected: index)
            }
        )
    }
    
    
}

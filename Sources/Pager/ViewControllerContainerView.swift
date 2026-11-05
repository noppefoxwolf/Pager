import SwiftUI
import UIKit

@MainActor
open class ViewControllerContainerView: UIView {

    public let contentViewController: UIViewController

    /// Set to `false` when using the iOS 18 palette APIs and provide `parentViewController` explicitly.
    public var automaticParentResolution: Bool = true {
        didSet {
            updateContainment()
        }
    }

    public weak var parentViewController: UIViewController? = nil {
        didSet {
            guard !automaticParentResolution else { return }
            updateContainment()
        }
    }

    private weak var installedParentViewController: UIViewController?

    public init(
        viewController: UIViewController,
    ) {
        self.contentViewController = viewController

        super.init(frame: .zero)
        
        backgroundColor = .clear
    }

    public init<RootView: View>(
        rootView: RootView,
        safeAreaRegions: SafeAreaRegions = []
    ) {
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.safeAreaRegions = safeAreaRegions
        hostingController.sizingOptions = [.intrinsicContentSize]
        hostingController.view.backgroundColor = .clear
        self.contentViewController = hostingController

        super.init(frame: .zero)
        
        backgroundColor = .clear
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateContainment()
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        updateContainment()
        addContentViewIfNeeded()
    }

    private func updateContainment() {
        let resolvedParent = resolveParentViewController()

        guard installedParentViewController !== resolvedParent else {
            return
        }

        removeContentViewController()

        guard let resolvedParent else {
            return
        }

        addContentViewController(to: resolvedParent)
    }

    private func resolveParentViewController() -> UIViewController? {
        if automaticParentResolution {
            return nearestViewController
        }

        return parentViewController
    }

    private func addContentViewController(
        to parentViewController: UIViewController
    ) {
        precondition(
            contentViewController.parent == nil,
            "contentViewController already has a parent."
        )

        parentViewController.addChild(contentViewController)
        contentViewController.didMove(toParent: parentViewController)

        installedParentViewController = parentViewController
    }

    private func addContentViewIfNeeded() {
        guard window != nil, contentViewController.parent != nil else {
            return
        }

        if contentViewController.viewIfLoaded?.superview === self {
            return
        }

        contentViewController.loadViewIfNeeded()
        guard let contentView = contentViewController.viewIfLoaded else { return }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func removeContentViewController() {
        guard contentViewController.parent != nil else {
            installedParentViewController = nil
            return
        }

        contentViewController.willMove(toParent: nil)
        contentViewController.removeFromParent()

        installedParentViewController = nil
    }

    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = self

        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }

            responder = nextResponder
        }

        return nil
    }
}

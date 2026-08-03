import SwiftUI
import UIKit

@MainActor
open class ViewControllerContainerView: UIView {

    public let contentViewController: UIViewController

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
    }

    public init<RootView: View>(
        rootView: RootView,
    ) {
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.safeAreaRegions = []
        hostingController.view.backgroundColor = .clear
        self.contentViewController = hostingController

        super.init(frame: .zero)
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
    }

    private func updateContainment() {
        let resolvedParent = resolveParentViewController()

        guard installedParentViewController !== resolvedParent else {
            return
        }

        uninstallViewController()

        guard let resolvedParent else {
            return
        }

        installViewController(in: resolvedParent)
    }

    private func resolveParentViewController() -> UIViewController? {
        if automaticParentResolution {
            return nearestViewController
        }

        return parentViewController
    }

    private func installViewController(
        in parentViewController: UIViewController
    ) {
        precondition(
            contentViewController.parent == nil,
            "contentViewController already has a parent."
        )

        parentViewController.addChild(contentViewController)
        addContentViewIfNeeded()
        contentViewController.didMove(toParent: parentViewController)

        installedParentViewController = parentViewController
    }

    private func addContentViewIfNeeded() {
        guard contentViewController.view.superview !== self else {
            return
        }

        addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func uninstallViewController() {
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

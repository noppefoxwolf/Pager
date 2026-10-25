import UIKit

// workaround: 直接additionalSafeAreaInsetsを触らないようにするために、PageItemViewControllerを噛ませる
final class PageItemViewController: UIViewController {
    let viewController: UIViewController
    private let horizontalSafeAreaInsetsProvider: () -> UIEdgeInsets

    init(
        viewController: UIViewController,
        contentInsets: UIEdgeInsets,
        horizontalSafeAreaInsetsProvider: @escaping () -> UIEdgeInsets
    ) {
        self.viewController = viewController
        self.horizontalSafeAreaInsetsProvider = horizontalSafeAreaInsetsProvider
        super.init(nibName: nil, bundle: nil)
        additionalSafeAreaInsets = contentInsets
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.rightAnchor.constraint(equalTo: viewController.view.rightAnchor),
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // UIKit changes a moving page's inherited safe area. Correct this
        // controller's measured insets to the horizontal target owned by the pager.
        let desiredInsets = horizontalSafeAreaInsetsProvider()
        let currentInsets = view.safeAreaInsets
        var insets = additionalSafeAreaInsets
        insets.left += desiredInsets.left - currentInsets.left
        insets.right += desiredInsets.right - currentInsets.right
        if additionalSafeAreaInsets != insets {
            additionalSafeAreaInsets = insets
        }
    }

    override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        guard isViewLoaded else { return nil }
        guard viewController.isViewLoaded else { return nil }
        return viewController.contentScrollView(for: edge)
    }
}

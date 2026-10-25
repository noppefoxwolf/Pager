import UIKit

// workaround: 直接additionalSafeAreaInsetsを触らないようにするために、PageItemViewControllerを噛ませる
final class PageItemViewController: UIViewController {
    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
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
        guard let pager = parent as? PageViewController else { return }
        let targetInsets = pager.view.safeAreaInsets
        let contentInsets = pager.itemContentInsets
        let currentInsets = view.safeAreaInsets
        var insets = additionalSafeAreaInsets
        // Keep page content margins stable as the page moves through the viewport.
        insets.left =
            max(0, insets.left) + targetInsets.left
            + max(0, contentInsets.left) - currentInsets.left
        insets.right =
            max(0, insets.right) + targetInsets.right
            + max(0, contentInsets.right) - currentInsets.right
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

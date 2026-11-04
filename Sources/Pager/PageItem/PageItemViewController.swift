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

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(viewController)
        viewController.loadViewIfNeeded()
        guard let contentView = viewController.viewIfLoaded else { return }
        view.addSubview(contentView)
        viewController.didMove(toParent: self)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }

    // Correct the inherited area before UIKit propagates it to the child. Waiting until
    // viewWillLayoutSubviews lets offscreen pages publish a transient horizontal inset,
    // which can make hosted text reflow even when the final layout has the right width.
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
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

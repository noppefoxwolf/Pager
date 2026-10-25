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

    var itemContentInsets: UIEdgeInsets = .zero {
        didSet { updateHorizontalSafeArea() }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateHorizontalSafeArea()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHorizontalSafeArea()
    }

    private func updateHorizontalSafeArea() {
        guard let parent, let contentView = viewIfLoaded?.superview else { return }
        let pagerInsets = parent.view.safeAreaInsets
        let inheritedInsets = contentView.safeAreaInsets
        var insets = itemContentInsets
        // Compensate for UIKit's viewport intersection so both pages retain
        // the pager's horizontal safe area throughout an interactive swipe.
        insets.left += pagerInsets.left - inheritedInsets.left
        insets.right += pagerInsets.right - inheritedInsets.right
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

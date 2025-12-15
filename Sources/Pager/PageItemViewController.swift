import UIKit

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
    
    override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        guard isViewLoaded else { return nil }
        guard viewController.isViewLoaded else { return nil }
        return viewController.contentScrollView(for: edge)
    }
}

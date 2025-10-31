import UIKit

final class PageItemViewController: UIViewController {
    let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewController.willMove(toParent: self)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        viewController.contentScrollView(for: edge)
    }
}

import UIKit
import Pager
import os

final class PageViewController: Pager.PageViewController, Pager.PageViewControllerDelegate {
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        if navigationItem.title == nil {
            navigationItem.title = "Pager Example"
        }
        
        let interaction = UIScrollEdgeElementContainerInteraction()
        interaction.scrollView = collectionView
        interaction.edge = .top
        pageTabBar.addInteraction(interaction)
        collectionView.superview!.addSubview(pageTabBar)
        pageTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.topEdgeEffect.style = .hard
        itemContentInsets.top = pageTabBar.intrinsicContentSize.height
        
        reloadData()
        
        let decrementButton = UIBarButtonItem(
            image: UIImage(systemName: "minus"),
            primaryAction: UIAction { [unowned self] _ in
                if !pages.isEmpty {
                    pages.removeLast()
                }
            }
        )
        let incrementButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { [unowned self] _ in
                // random length words
                let phrases: [String] = [
                    "🦊",
                    "For you",
                    "Buisiness & Finance",
                    "Entertainment, Fun, Games & More",
                ]
                let phrase = phrases.randomElement()!
                let tab = Page(
                    id: UUID().uuidString,
                    title: phrase,
                    viewControllerProvider: { tab in
                        //ChildViewController(text: tab.title)
                        let vc = TableViewController(style: .plain)
                        vc.title = phrase
                        return vc
                    }
                )
                pages.append(tab)
            }
        )
        
        navigationItem.rightBarButtonItems = [
            incrementButton,
            decrementButton,
        ]
    }
    
    func willTransition(to pendingViewControllers: [UIViewController]) {
        logger.debug("willTransition: \(pendingViewControllers.compactMap(\.title))")
    }
    
    func didFinishTransition(_ pageViewController: Pager.PageViewController) {
        logger.debug("didFinishTransition")
    }
}

extension PageViewController {
    static func seededPages() -> [Page] {
        [
            Page(
                id: "home",
                title: "Home",
                viewControllerProvider: { page in
                    ChildViewController(text: page.title)
                }
            ),
            Page(
                id: "table",
                title: "Table",
                viewControllerProvider: { _ in
                    TableViewController(style: .plain)
                }
            ),
            Page(
                id: "collection",
                title: "Collection",
                viewControllerProvider: { _ in
                    CollectionViewController(style: .insetGrouped)
                }
            ),
        ]
    }
}

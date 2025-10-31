import UIKit
import Pager

final class PageViewController: Pager.PageViewController, Pager.PageTabBarDataSource, Pager.PageViewControllerDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        pageTabBar.tabBarDataSource = self
        
        navigationItem.title = "Pager Example"
        
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
            pageTabBar.heightAnchor.constraint(equalToConstant: 34),
        ])
        
        collectionView.topEdgeEffect.style = .hard
        itemContentInsets.top = 34
        
        let decrementButton = UIBarButtonItem(
            image: UIImage(systemName: "minus"),
            primaryAction: UIAction { [unowned self] _ in
                if !items.isEmpty {
                    items.removeLast()
                }
                self.reloadData()
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
                items.append(phrases.randomElement()!)
                self.reloadData()
            }
        )
        
        navigationItem.rightBarButtonItems = [
            incrementButton,
            decrementButton,
        ]
        
        reloadData()
    }
    
    var items: [String] = []
    
    func numberOfItems(in bar: PageTabBar) -> Int {
        items.count
    }
    
    func pageTabBar(_ bar: PageTabBar, controlForItemAt index: Int) -> any PageTabBarItem {
        DefaultPageTabBarItem(title: items[index])
    }
    
    func numberOfViewControllers(
        in pageViewController: Pager.PageViewController
    ) -> Int {
        items.count
    }
    
    func viewController(
        for pageViewController: Pager.PageViewController,
        at index: Int
    ) -> UIViewController? {
        if items.indices.contains(index) {
            //ChildViewController(text: items[index])
            //TableViewController(style: .plain)
            CollectionViewController(style: .plain)
        } else {
            nil
        }
    }
}

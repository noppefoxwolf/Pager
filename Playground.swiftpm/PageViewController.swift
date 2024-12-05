import UIKit
import Pager

final class PageViewController: Pager.PageViewController, Pager.PageTabBarDataSource, Pager.PageViewControllerDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        pageTabBar.tabBarDataSource = self
        
        navigationItem.title = "Pager Example"
        let palette = NavigationBarPalette(contentView: pageTabBar)
        palette.setPreferredHeight(34)
        navigationItem.setBottomPalette(palette)
        
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
            CollectionViewController(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain)))
        } else {
            nil
        }
    }
}




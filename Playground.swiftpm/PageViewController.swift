import UIKit
import Pager

final class PageViewController: Pager.PageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                if !tabs.isEmpty {
                    tabs.removeLast()
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
                let tab = PageTab(
                    id: UUID().uuidString,
                    title: phrase,
                    viewControllerProvider: { tab in
                        ChildViewController(text: tab.title)
                    }
                )
                tabs.append(tab)
            }
        )
        
        navigationItem.rightBarButtonItems = [
            incrementButton,
            decrementButton,
        ]
    }
}

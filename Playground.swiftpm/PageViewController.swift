import UIKit
import Pager
import os

final class PageViewController: Pager.PageViewController, Pager.PageViewControllerDelegate {
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )

    private lazy var editButton = UIBarButtonItem(
        image: UIImage(systemName: "pencil"),
        primaryAction: UIAction { [unowned self] _ in
            presentTitleEditor()
        }
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
        
        let decrementButton = UIBarButtonItem(
            image: UIImage(systemName: "minus"),
            primaryAction: UIAction { [unowned self] _ in
                if !pages.isEmpty {
                    pages.removeLast()
                    updateEditButtonState()
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
                updateEditButtonState()
            }
        )
        
        navigationItem.rightBarButtonItems = [
            incrementButton,
            decrementButton,
            editButton,
        ]
        updateEditButtonState()
    }
    
    func willTransition(to pendingViewControllers: [UIViewController]) {
        logger.debug("willTransition: \(pendingViewControllers.compactMap(\.title))")
    }
    
    func didFinishTransition(_ pageViewController: Pager.PageViewController) {
        logger.debug("didFinishTransition")
    }
}

private extension PageViewController {
    var currentPageIndex: Int? {
        let width = collectionView.bounds.width
        guard width > 0 else { return nil }
        let value = collectionView.contentOffset.x / width
        guard value.isFinite else { return nil }
        let index = Int(value.rounded())
        return pages.indices.contains(index) ? index : nil
    }
    
    func updateEditButtonState() {
        editButton.isEnabled = !pages.isEmpty
    }
    
    func presentTitleEditor() {
        guard let index = currentPageIndex else { return }
        let page = pages[index]
        
        let alert = UIAlertController(title: "Edit Title", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = page.title
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let newTitle = alert?.textFields?.first?.text?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""
            guard !newTitle.isEmpty else { return }
            updatePageTitle(at: index, title: newTitle)
        })
        
        present(alert, animated: true)
    }
    
    func updatePageTitle(at index: Int, title: String) {
        guard pages.indices.contains(index) else { return }
        let page = pages[index]
        let viewController = page.viewController
        viewController.title = title
        if let childViewController = viewController as? ChildViewController {
            childViewController.label.text = title
        }
        
        let updatedPage = Page(
            id: page.id,
            title: title,
            viewControllerProvider: { _ in
                viewController
            }
        )
        pages[index] = updatedPage
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

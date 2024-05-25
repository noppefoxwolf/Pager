import UIKit

open class PageViewController: UICollectionViewController {
    public weak var dataSource: (any PageViewControllerDataSource)? = nil
    public let pageTabBar = PageTabBar()
    var hostedViewControllers: Set<UIViewController> = []

    public init() {
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func loadView() {
        super.loadView()

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        let layout = UICollectionViewCompositionalLayout.paging(
            visibleItemsInvalidationHandler: { [weak self] (items, point, environment) in
                self?.onUpdatedPageProgress(point.x / environment.container.contentSize.width)
            }
        )
        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    func onUpdatedPageProgress(_ progress: Double) {
        pageTabBar.setIndicator(progress)

        let index = Int(progress + 0.5)
        let vc = dataSource?.viewController(for: self, at: index)
        let sv = vc?.contentScrollView(for: .top) ?? (vc?.view as? UIScrollView)
        setContentScrollView(sv, for: .top)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        pageTabBar.frame.size.height = 34
        pageTabBar.delegate = self
    }

    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataSource?.numberOfViewControllers(in: self) ?? 0
    }

    open override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        1
    }

    open override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach({ $0.removeFromSuperview() })

        if let viewController = dataSource?.viewController(for: self, at: indexPath.section) {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
            viewController.didMove(toParent: nil)

            viewController.willMove(toParent: self)
            addChild(viewController)
            hostedViewControllers.insert(viewController)
            cell.contentView.addSubview(viewController.view)
            viewController.didMove(toParent: self)
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                cell.contentView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
                viewController.view.leadingAnchor.constraint(
                    equalTo: cell.contentView.leadingAnchor
                ),
                cell.contentView.trailingAnchor.constraint(
                    equalTo: viewController.view.trailingAnchor
                ),
            ])
        }
        return cell
    }

    public func reloadData() {
        hostedViewControllers.forEach({ $0.removeFromParent() })
        hostedViewControllers = []
        collectionView.reloadData()
        pageTabBar.reloadData(dataSource?.numberOfViewControllers(in: self) ?? 0)
    }
}

extension PageViewController: PageTabBarDelegate {
    func pageTabBar(_ pageTabBar: PageTabBar, didSelected index: Int) {
        collectionView.scrollToItem(
            at: IndexPath(row: 0, section: index),
            at: .centeredHorizontally,
            animated: true
        )
    }
}

extension UICollectionViewLayout {
    static func paging(
        visibleItemsInvalidationHandler: @escaping
        NSCollectionLayoutSectionVisibleItemsInvalidationHandler
    ) -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        configuration.contentInsetsReference = .none
        return UICollectionViewCompositionalLayout(
            sectionProvider: { section, environment in
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 1
                )
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
                return section
            },
            configuration: configuration
        )
    }
}

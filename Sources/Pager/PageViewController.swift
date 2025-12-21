import UIKit
import os
import ViewControllerContentConfiguration

open class PageViewController: WorkaroundCollectionViewController {
    public let pageTabBar = PageTabBar()
    
    lazy var dataSource = UICollectionViewDiffableDataSource<Int, Page.ID>(
        collectionView: collectionView,
        cellProvider: { [unowned self] collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    )
    
    public var itemContentInsets: UIEdgeInsets = .zero {
        didSet {
            Task {
                await reloadData()
            }
        }
    }
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public var pages: [Page] = [] {
        didSet {
            pagesByID = Dictionary(uniqueKeysWithValues: pages.map { ($0.id, $0) })
            Task {
                await reloadData()
            }
        }
    }
    
    public init(pages: [Page] = []) {
        self.pages = pages
        super.init(collectionViewLayout: .paging())
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        super.loadView()
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        _ = cellRegistration
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTabBar.tabBarDelegate = self
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        update(percentComplete)
    }
    
    private var pagesByID: [Page.ID: Page] = [:] {
        didSet {
            pageTabBar.pagesByID = pagesByID
        }
    }
    
    lazy var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Page.ID>(
        handler: { [unowned self] cell, indexPath, item in
            guard let page = pagesByID[item] else {
                cell.contentConfiguration = nil
                return
            }
            let contentViewController = page.viewControllerProvider(page)
            let viewController = PageItemViewController(viewController: contentViewController)
            viewController.additionalSafeAreaInsets = itemContentInsets
            cell.contentConfiguration = cell.viewControllerConfiguration(
                viewController: viewController,
                parent: self
            )
        }
    )
    
    open override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = pageTabBar.contentOffset
        let width = pageTabBar.bounds.size.width
        
        guard width > 0 else { return }
        let index = round(offset.x / width)
        guard index.isNormal else { return }
        
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        coordinator.animate(
            alongsideTransition: { [unowned pageTabBar] (context) in
                pageTabBar.reloadData()
                pageTabBar.setContentOffset(newOffset, animated: false)
            },
            completion: nil
        )
    }
    
    var percentComplete: CGFloat {
        let width = collectionView.bounds.size.width
        guard width > 0 else { return 0.0 }
        let value = collectionView.contentOffset.x / width
        guard !value.isNaN && value.isFinite else { return 0.0 }
        let maxValue = CGFloat(pages.count - 1)
        let minValue = 0.0
        guard maxValue > 0 else { return 0.0 }
        let range = minValue...maxValue
        let clampedValue = min(range.upperBound, max(range.lowerBound, value))
        return clampedValue
    }
    
    var indexPathForCenterItem: IndexPath? {
        let x = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let y = collectionView.bounds.height / 2
        return collectionView.indexPathForItem(at: CGPoint(x: x, y: y))
    }
    
    func update(_ percentComplete: Double) {
        pageTabBar.setIndicator(percentComplete)
    }
    
    @MainActor
    public func reloadData() async {
        guard isViewLoaded else { return }
        
        pagesByID = Dictionary(uniqueKeysWithValues: pages.map { ($0.id, $0) })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Page.ID>()
        for (offset, tab) in pages.enumerated() {
            snapshot.appendSections([offset])
            snapshot.appendItems([tab.id], toSection: offset)
        }
        
        await dataSource.apply(snapshot, animatingDifferences: false)
        
        var tabBarSnapshot = NSDiffableDataSourceSnapshot<Int, Page.ID>()
        tabBarSnapshot.appendSections([0])
        tabBarSnapshot.appendItems(pages.map(\.id), toSection: 0)
        await pageTabBar.tabBarDataSource.apply(tabBarSnapshot, animatingDifferences: false)
        
        pageTabBar.indicatorView.isHidden = pages.count == 0
        
        view.setNeedsLayout()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        update(percentComplete)
    }
    
    open override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        guard isViewLoaded else { return nil }
        let contentConfiguration = collectionView.visibleCells.first?.contentConfiguration as? ViewControllerContentConfiguration
        return contentConfiguration?.viewController.contentScrollView(for: edge)
    }
}

extension PageViewController: PageTabBarDelegate {
    func pageTabBar(_ pageTabBar: PageTabBar, didSelected index: Int) {
        collectionView.scrollToItem(
            at: IndexPath(row: 0, section: index),
            at: .centeredHorizontally,
            animated: true
        )
        // 既に選択済みのアイテムを選択するとスクロールが発生しないので１度呼ぶ
        pageTabBar.setIndicator(percentComplete)
    }
}

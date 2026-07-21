import UIKit
import os
import SwiftUI
import ViewControllerContentConfiguration

open class PageViewController: WorkaroundCollectionViewController {
    private let pageTabBarState: PageTabBarState
    private let pageTabBarController: UIHostingController<PageTabBar>
    private let pageTabBar: UIView
    
    lazy var dataSource = UICollectionViewDiffableDataSource<Section, Page.ID>(
        collectionView: collectionView,
        cellProvider: { [unowned self] collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    )
    public weak var delegate: (any PageViewControllerDelegate)? = nil
    
    public var itemContentInsets: UIEdgeInsets = .zero {
        didSet {
            reconfigure()
        }
    }
    
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: #file
    )
    
    public var pages: [Page] = [] {
        didSet {
            pagesByID = Dictionary(uniqueKeysWithValues: pages.map { ($0.id, $0) })
            reloadData()
        }
    }
    
    // TODO: setPages
    
    public init(pages: [Page] = []) {
        let pageTabBarState = PageTabBarState()
        pageTabBarState.pages = pages
        let pageTabBarController = UIHostingController(
            rootView: PageTabBar(state: pageTabBarState)
        )
        pageTabBarController.safeAreaRegions = []
        pageTabBarController.view.backgroundColor = .clear

        self.pageTabBarState = pageTabBarState
        self.pageTabBarController = pageTabBarController
        self.pageTabBar = pageTabBarController.view
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
        
        pageTabBarState.onSelect = { [weak self] index in
            self?.selectPage(at: index)
        }
    }

    /// Attaches the tab bar view and completes its view controller containment.
    @MainActor
    public func attachPageTabBar(using body: (UIView) -> Void) {
        guard pageTabBarController.parent == nil else { return }

        addChild(pageTabBarController)
        body(pageTabBar)
        pageTabBarController.didMove(toParent: self)
    }

    /// Removes the tab bar view and tears down its view controller containment.
    @MainActor
    public func detachPageTabBar(using body: (UIView) -> Void) {
        guard pageTabBarController.parent === self else {
            body(pageTabBar)
            return
        }

        pageTabBarController.willMove(toParent: nil)
        body(pageTabBar)
        pageTabBarController.removeFromParent()
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        reloadData()
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        update(percentComplete)
    }
    
    private var pagesByID: [Page.ID: Page] = [:]
    
    lazy var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Page.ID>(
        handler: { [unowned self] cell, indexPath, item in
            guard let page = pagesByID[item] else {
                cell.contentConfiguration = nil
                return
            }
            let contentViewController = page.viewController
            let viewController = PageItemViewController(viewController: contentViewController)
            viewController.additionalSafeAreaInsets = itemContentInsets
            cell.contentConfiguration = cell.viewControllerConfiguration(
                viewController: viewController,
                parent: self
            )
        }
    )
    
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
        pageTabBarState.position = percentComplete
    }
    
    @MainActor
    public func reloadData() {
        guard isViewLoaded else { return }
        
        pagesByID = Dictionary(uniqueKeysWithValues: pages.map { ($0.id, $0) })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Page.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pages.map(\.id), toSection: .main)
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        
        let diff = dataSource.snapshot().itemIdentifiers.difference(from: snapshot.itemIdentifiers)
        
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self else { return }
            if !diff.isEmpty {
                delegate?.didFinishTransition(self)
            }
        }
        pageTabBarState.pages = pages
        pageTabBarState.position = percentComplete
        
        view.setNeedsLayout()
    }
    
    func reconfigure() {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        update(percentComplete)
    }
    
    open override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        guard isViewLoaded else { return nil }
        guard let indexPath = indexPathForCenterItem else { return nil }
        return pages[indexPath.row].viewController.contentScrollView(for: edge)
    }
    
    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.didFinishTransition(self)
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didFinishTransition(self)
    }
    
    open override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        delegate?.willTransition(to: [pages[indexPath.row].viewController])
    }
}

private extension PageViewController {
    func selectPage(at index: Int) {
        collectionView.scrollToItem(
            at: IndexPath(row: index, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
        // 既に選択済みのアイテムを選択するとスクロールが発生しないので１度呼ぶ
        pageTabBarState.position = percentComplete
    }
}
